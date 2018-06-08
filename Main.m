%====================����һ֡һ֡����=================%
%====================ÿһ֡��10����֡=================%
%====================BLOCK_NUM=10=================%
clear all;
close all;
clc;
addpath(genpath(pwd));
global_parameters;
config_global_parameters();
Snr = [-7,-6,-5,-4,-3,-2,-1,0,1,2];
% Snr = [5,6];
Rx_CFO = [(2*rand(1, 1)-1)*0.1 (2*rand(1, 1)-1)*5];
%% General parameters
nid_1 = 200;
nid_2 = 0;
NID = 3*nid_1 + nid_2;
BW = 5;         %MHz
CFO_per_ppm = 4; %kHz
TTIs=20;      %�������е���������
PerNum = 1;
BloPer = 1;
% ͬ������ʱƵ��ʼλ��
k0_pss = NUM_USED_SUBCARRIER/2-PSS_ALLOCATED_LENGTH/2;
l_pss = 3;
k0_sss = NUM_USED_SUBCARRIER/2-PSS_ALLOCATED_LENGTH/2;
l_sss = l_pss+2;
sss_pss_distance = 2*(CP_LENGTH_SHORT+IFFT_SIZE);
% Rx parameters
N = 1;                    %�²�������
% ���ڵ��ԡ�����ƽ̨
PSS_first_position = SUBFRAME_LEN/2 - (IFFT_SIZE+CP_LENGTH_SHORT)*4 -IFFT_SIZE + 1;

right_detect_normal = [];
right_detect_normal_large_cfo = [];
right_pbch_arr = [];
pbch_trans_arr = [];
BER = [];
%% PBCH��������
RS_MAP_MATRIX = get_DMRS_MATRIX(NID);
DATA_NUM = sum(sum(RS_MAP_MATRIX==1));                 % DCI RE��
DMRSNum = sum(sum(RS_MAP_MATRIX==2));                 % DMRS RE��
[DMRS_LOCATION,DATA_LOCATION] = getDMRS_DATA_location();
pbch_len = 8;
rateMatch_len = 864;
% pbch_data = prbs15_lc(pbch_len);
crcLen = 24;
DLUL = 1;
L=8; %���������
[crcEncObj, crcDecObj] = getCRCObj(crcLen);
PolarParam = PC_Construction(rateMatch_len,pbch_len+crcLen, DLUL);
channelIntlv = getChannelIntlv(rateMatch_len,DLUL,PolarParam);
[UCIData, PolarOut] = Polar_Encode(pbch_len,rateMatch_len,crcLen,PolarParam,channelIntlv,crcEncObj); %��������ƥ������ı�����һ��864��bit
pbchData = qpsk(PolarOut); %�������ƣ�864��bitӳ��Ϊ432��������֮��Ҫ������Դӳ��
%��pbch���ݷֿ鲢���DMRS
[ pbchData1,pbchData21,pbchData22,pbchData3 ] = genPBCHBlock( pbchData,NID );

%% �ŵ�����
TU_channel_EPA_genetate_hou
% ����RHH��RDH����������
R_hh_dh_viena_DMRS;
% waitbar�����ľ������ʾ�������н�����
% hwait = waitbar(0,'��ȴ�>>>>>>>>'); 
% snr_array_length = length(Snr);
% step=snr_array_length/100;
for SnrInd = 1:length(Snr)
    % ͬ���ɹ�������ʼ��
    right_detect1 = 0;
    right_detect2 = 0;
    right_pbch = 0;
    pbch_trans = 0;
    err_bit = 0;
    %% ������
%      if snr_array_length-SnrInd<=0
%          waitbar(SnrInd/snr_array_length,hwait,'�������');
%          pause(0.05);
%      else
%          PerStr=fix(SnrInd/step);                % fix����0��£ȡ���������������аٷֱ�
%          str=['�������У� ',num2str(PerStr),'%'];   % ��1��BlockNum�������㵽1��100�ڣ�����������н��Ȱٷֱ� 
%          waitbar(SnrInd/snr_array_length, hwait, str);
%          pause(0.05);
%      end
for I = 1:TTIs
    %% DL data generate and Mapping
    initialdata = round(rand(1,NUM_BITS_PER_FRAME));                   %initial data for DL(Physical channel, after channel coding and scrambling);
    [modout] = qpsk(initialdata);                                  %modulation
    data = reshape(modout,NUM_USED_SUBCARRIER,NUM_OFDM_PER_FRAME);
    %% PSS/SSS generate
    % add your codes here(PSS/SSS generate): 
    
    PSS1 = PSS(nid_2);% pss����
    SSS1 = SSS(nid_1,nid_2);
    pss_length = length(PSS1);
    sss_length = length(SSS1);
    PSS_tx = [zeros(1,ceil((NUM_USED_SUBCARRIER-pss_length)/2)) PSS1 zeros(1,floor((NUM_USED_SUBCARRIER-pss_length)/2))];
    SSS_tx = [zeros(1,ceil((NUM_USED_SUBCARRIER-sss_length)/2)) SSS1 zeros(1,floor((NUM_USED_SUBCARRIER-sss_length)/2))];
    %% PSS/SSS mapping
    for i = 1:1                                                                       %PSS mapping
        data([1:NUM_USED_SUBCARRIER],l_pss+14*(i-1)) = PSS_tx;            %the frequency resource here is for PSS
        data([1:NUM_USED_SUBCARRIER],l_pss+14*(i-1)+1) = pbchData1;
        data([1:NUM_USED_SUBCARRIER],l_pss+14*(i-1)+3) = pbchData3;
        data([1:NUM_USED_SUBCARRIER],l_sss+14*(i-1)) = SSS_tx;          %the frequency resource here is for SSS0
        data([1:48],l_sss+14*(i-1)) = pbchData21;
        data([NUM_USED_SUBCARRIER-47:NUM_USED_SUBCARRIER],l_sss+14*(i-1)) = pbchData22;
%         data([1:NUM_USED_SUBCARRIER],NUM_OFDM_PER_FRAME/2+l_pss+14*(i-1)) = PSS_tx;            %the frequency resource here is for PSS
%         data([1:NUM_USED_SUBCARRIER],NUM_OFDM_PER_FRAME/2+l_sss+14*(i-1)) = SSS_tx;          %the frequency resource here is for SSS0 
    end
    %% OFDM modulation
    [ofdm_out1]=ofdm_mod(data,IFFT_SIZE,NUM_OFDM_SLOT,CP_LENGTH_LONG,CP_LENGTH_SHORT);  
    %% add TRP frequency offset ��0.05ppm���ȷֲ�
    CFO_TRP = (2*rand(1, 1)-1)*0.05;                                                  %ppm
    ofdm_out = ofdm_out1; %.*exp(j*2*pi*CFO_TRP*CFO_per_ppm*1e3*([0:length(ofdm_out1)-1])*Ts); 
    
%     %��ʼ��ǰ�����
%     PreInterfere=zeros(1,SUBFRAME_LEN);
%     channel_out = [];
%     fft_size_minus = IFFT_SIZE-1;
%     train_ofdm_out=[zeros(1,CP_LENGTH_LONG), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), ...
%                     zeros(1,CP_LENGTH_LONG), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus)];                                     
%     train_ofdm_temp = train_ofdm_out;
       %% �ŵ� EPA
%     if Ind == 1
%             PreviousTrain=zeros(UE_ANT_NUM*NB_ANT_NUM,T);
%             TrainInterfere=zeros(UE_ANT_NUM*NB_ANT_NUM,T);
%     end

        %% ������ؾ���
    channel_out = [];
    for block_index = 1:BLOCK_NUM
        if block_index == 1
            PreInterfere=zeros(UE_ANT_NUM*NB_ANT_NUM,T);
        end
        % ��ȡ�����ŵ��ļ�
        [H, delay_out, mul_path ] = TU_channel_EPA_from_file(block_index);
        % ��TDL-A�ŵ� 
        [channel_out_end,SignalInterfere]=TU_channel_new(ofdm_out(:,SUBFRAME_LEN*(block_index-1)+1:SUBFRAME_LEN*block_index),PreInterfere,H,delay_out,mul_path);
%         [channel_out_train,TrainInterfere] = TU_channel_new(train_ofdm_temp, PreviousTrain, H, delay_out, mul_path);  
        % ����ǰ�����td_pss_tx
        PreInterfere = SignalInterfere;
%         PreviousTrain = TrainInterfere; 
        channel_out = [channel_out, channel_out_end];
    end
    % ��ÿ������ȵ㵥���ֱ����һ�²���
    % ��AWGN�ŵ�
    SnrLinear = 10^(Snr(SnrInd)/10);     
    NoiseVec = Awgn_Gen(channel_out, SnrLinear);               
    DataAwgn = channel_out + NoiseVec;  

     %pss���Ժ�ӵ�
    CFO_Rx = (2*rand(1, 1)-1)*0.1;                                                       %ppm ��0.1ppm���ȷֲ�
    data_Rx1 = DataAwgn;%.*exp(j*2*pi*CFO_Rx*CFO_per_ppm*1e3*([0:length(ofdm_out1)-1])*Ts);

   %% С������  0.1/0.05ppm 
    [ceil_id2, Pss_location, CFO] = PSS_detect(data_Rx1, IFFT_SIZE, N, 10000 ,CP_LENGTH_SHORT,1);
    Pss_location
    data_Rx1=data_Rx1;%.*exp(-1*j*2*pi*CFO*([0:length(ofdm_out1)-1])*Ts);
    rx_pss = data_Rx1(Pss_location:Pss_location+IFFT_SIZE-1);
    %����pss����sss���ŵ�����
    channel_ls = ChannelEstmate_SSS( rx_pss, IFFT_SIZE, ceil_id2 );
    %����SSS
    rx_sss = data_Rx1(Pss_location+sss_pss_distance:Pss_location+sss_pss_distance+IFFT_SIZE-1);
    
    % ��ȡRHH��RDH����
    R_dh0_DMRS = Rdh(:,:,1);
    R_hh0_DMRS = Rhh(:,:,1);
    R_hh0_PSS = R_hh_PSS(:,:,1);
    %Ƶ��SSS��� ------- ������ܺ���Ҫ����Ҫ�Ż�   
    channel_sss = channelEst_SSS_MMSE( channel_ls, R_hh0_PSS, SnrLinear );
    [id1,  max_corr] = SSS_detect(rx_sss, nid_2, channel_sss.', IFFT_SIZE);
    %% PBCH�������
    %����nid
%     rx_nid = id1*3 + ceil_id2;
    rx_nid = 600;
    %���뺬��pbch�ķ��ţ�ȥcp
    PBCHSymbols = data_Rx1(Pss_location+IFFT_SIZE:Pss_location+IFFT_SIZE+3*(IFFT_SIZE+CP_LENGTH_SHORT)-1);
    PBCHSymbols = reshape(PBCHSymbols,IFFT_SIZE+CP_LENGTH_SHORT,3);
    PBCHSymbols(1:CP_LENGTH_SHORT,:) = [];
    %��ofdm
    rx_PBCHDataAndSSS = [];
    for i=1:3
    rx_PBCHDataAndSSS = [rx_PBCHDataAndSSS deofdm(PBCHSymbols(:,i).',NUM_USED_SUBCARRIER,IFFT_SIZE)];
    end
    
%     [H_Ideal, HPilott, HPSSt] = CE_LS(channel_out_train,3,600);
%     
    %�����pbch����
    [rx_PBCHDataToDeqpsk,rx_dmrs] = getPBCHData( rx_PBCHDataAndSSS,rx_nid );
    h_dmrs = rx_dmrs./DMRS;  % LS���Ƶ�Ƶ���ŵ�
    
    
    % ʵ���ŵ�����
    H_est = Channel_estimation(h_dmrs, R_dh0_DMRS,R_hh0_DMRS, SnrLinear);               
    % MMSE���
    [ MMSEOut, MMSESinr ] = MMSE_detector_MIMO( rx_PBCHDataToDeqpsk,H_est, SnrLinear,NB_ANT_NUM);
    %��qpsk
    rx_PBCHDataToDePolar = Demodulation_data(MMSEOut, MMSESinr);
    %��Polar
    rx_PBCHData = Polar_Decode(rx_PBCHDataToDePolar,rateMatch_len,crcLen,PolarParam,L,channelIntlv,crcDecObj);
    bit_right = rx_PBCHData(1:8).' == UCIData
    if(isempty(find(bit_right==0)))
        right_pbch = right_pbch+1;
    end
    err_bit = err_bit + sum(bit_right == 0);
    % �ж��Ƿ���ɹ�
    if(id1==nid_1 && ceil_id2==nid_2 && abs(Pss_location-PSS_first_position)<=CP_LENGTH_SHORT/2)
        right_detect1 = right_detect1 + 1;
        
        pbch_trans = pbch_trans +1;
    end
end

right_detect_normal = [right_detect_normal right_detect1];
right_pbch_arr = [right_pbch_arr right_pbch];
pbch_trans_arr = [pbch_trans_arr pbch_trans];
BER = [BER err_bit/(8*TTIs)];
end
right_pbch_arr
pbch_trans_arr
% close(hwait);          % �رս�����
right_detect_normal = right_detect_normal./TTIs;
figure(10)
plot(Snr,right_detect_normal,'--+b')
title('���ϼ��ɹ���')
xlabel('����ȣ�dB��')
ylabel('һ�μ��PSS/SSS���ϼ��ɹ���')
% h = legend(['�Ż��㷨'],['��ͳ�㷨'],['�;�������'],'location','best');
% h = legend(['��ͳ�㷨'],'location','best');
h = legend(['0.05/0.1ppm 3km/h'],'best');
set(h,'Box','off');
set(gca,'YTick',0.4:0.1:1);

BLER = (TTIs-right_pbch_arr)./TTIs;
figure(1)
plot(Snr,BLER,'--+b')
hold on;
plot(Snr,BER,'--*r')
title('PBCH�����')
xlabel('����ȣ�dB��')
ylabel('����')
h = legend(['����BLER'],['����BER'],'best');
set(h,'Box','off');
% set(gca,'YTick',[0,0.001,0.01,0.1,1]);