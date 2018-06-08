%% �������ܣ�
%function used by R_hh_dh_calculation_viena
%% ���������
% DataOfdmIn���������������
%% �������
% DataSymOut�����������Դӳ����������
% PilotSymOut�����������Դӳ����DMRS
%% Modify history
% 2017/6/18 created by Bu Shuqing
% 2017/10/30 modified by Liu Chunhua
%% code
function [ HData, HPilot, HPSS] = CE_LS(DataOfdmIn,PBCHBeginOFDMIndex,nid)

global IFFT_SIZE;
global LONG_CP_PERIOD;
global CP_LENGTH_LONG;
global CP_LENGTH_SHORT;

ReFreNum = 240;
ReTimeNum = 7;
DataSymMatrix = zeros(ReFreNum, ReTimeNum);                                 % ϵͳʱƵ��Դ��

PosInd =0;
%% ��OFDM����
for TimeInd=1:ReTimeNum                                                     % �ж�CP����
    if mod(TimeInd,LONG_CP_PERIOD) == 1                                                             
        temp_Cp_length = CP_LENGTH_LONG;
    else 
        temp_Cp_length = CP_LENGTH_SHORT;
    end
    PosInd = PosInd + temp_Cp_length;
    data_to_FFT = DataOfdmIn(PosInd + (1: IFFT_SIZE));                        % ȥ��CP����ȡ���ݲ���
    post_FFT=fft(data_to_FFT);                                              % ����Ϊѵ�����ݣ����ó�FFT����
    DataSymMatrix((1:(ReFreNum/2)), TimeInd)=post_FFT((IFFT_SIZE-ReFreNum/2+1) : IFFT_SIZE);  %negative part
    DataSymMatrix(((ReFreNum/2+1):ReFreNum), TimeInd)=post_FFT(2:(ReFreNum/2)+1);         %positive part
    PosInd = PosInd + IFFT_SIZE;
end
%% �����PSS
PSSData = DataSymMatrix(:,PBCHBeginOFDMIndex).';
PSSData = PSSData(ceil((ReFreNum-127)/2)+1:ceil((ReFreNum-127)/2)+127);
%% �������PBCH�ķ���
PBCHData = DataSymMatrix(:,PBCHBeginOFDMIndex+1:PBCHBeginOFDMIndex+3); %һ��3������
[row,col] = size(PBCHData);
PBCHData = reshape(PBCHData,1,row*col);
%% �����PBCH
[DataSymOut,PilotSymOut] = getPBCHData( PBCHData, nid);
   HData = DataSymOut.';
   HPilot = PilotSymOut.';
   HPSS = PSSData.';
end

