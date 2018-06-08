%% �����ܣ�
% �������� 2D_viena �ŵ��������õ��ŵ������Ϣ��R_hh����ƵԪ������ؾ���R_dh�������뵼ƵԪ�ػ���ؾ��� 

% �����ŵ���ؾ���
for PerInd = 1 : PerNum
    R_hh_temp = 0;
    R_dh_temp = 0;
    R_hh_PSS_temp = 0;
    for Ind = 1:BloPer
        BlockIndex = (PerInd-1)*BloPer+Ind;
        %% ѵ������
        fft_size_minus = IFFT_SIZE-1;
        train_ofdm_out=[zeros(1,CP_LENGTH_LONG), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), ...
                        zeros(1,CP_LENGTH_LONG), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus)];                                     
        train_ofdm_temp = train_ofdm_out;
       %% �ŵ� EPA
        if Ind == 1
                PreviousTrain=zeros(UE_ANT_NUM*NB_ANT_NUM,T);
        end
        [H, delay_out, mul_path ] = TU_channel_EPA_from_file(BlockIndex);   %��ȡ�����ŵ��ļ�
        [channel_out_train,TrainInterfere] = TU_channel_new(train_ofdm_temp, PreviousTrain, H, delay_out, mul_path);  
        PreviousTrain = TrainInterfere; 
        %% ������ؾ���
         [HData, HPilot, HPSS] = CE_LS(channel_out_train,l_pss,NID);
         R_hh_temp = R_hh_temp + HPilot * HPilot';
         R_dh_temp = R_dh_temp + HData * HPilot';   
         R_hh_PSS_temp = R_hh_PSS_temp + HPSS*HPSS';
    end
    R_hh_temp = R_hh_temp/BloPer;
    R_dh_temp = R_dh_temp/BloPer;
    R_hh_PSS_temp = R_hh_PSS_temp/BloPer;
    R_hh(:,:,PerInd) = R_hh_temp;
    R_dh(:,:,PerInd) = R_dh_temp;
    R_hh_PSS(:,:,PerInd) = R_hh_PSS_temp;

    %% ����ʱ�������
    % Slot�ĳ���
    period=1*10^(-3)/(SUBCARRIER_SPACE/15);  
    % ��������Ƶƫ��Ƶ��Hz,�ٶ�m/s����λҪ��һ��
    fDmax = UE_SPEED*CARRIER_FREQUENCY/3e8;
    % ����ÿ�����ŵ�ʱ�䳤�ȣ�����CP
    SymbolDuration = period/SYMBOL_PER_SUBFRAME;
    DeltaT = (0:(SYMBOL_PER_SUBFRAME-1))*SymbolDuration;
    Rtt = besselj(0,2*pi*fDmax*DeltaT);

    %% ֻ����Ƶ���ֵ
    % lenRtt = length(Rtt);
    % Rtt = ones(1,lenRtt);
    %% ����Ƶ�������
    % �����ӳٹ�����
    for n = 1:(MAX_DELAY+1)
        index = find((DELAY_OUT+1)==n);
        PDP(n) = sum(Am(index).^2);
    end
    Rf = fft(PDP,IFFT_SIZE);%/sqrt(IFFT_SIZE);
    Rff = Rf.';

    %% ����ʱƵ���ŵ���ؾ���
    RffRtt = Rff*Rtt;
    %% �����ֵ����
    DMRSLen = size(DMRS_LOCATION,2);
    DataLen = size(DATA_LOCATION,2);
    PortNum = size(DMRS_LOCATION,3);

    Rhh = zeros(DMRSLen,DMRSLen,PortNum);
    Rdh = zeros(DataLen,DMRSLen,PortNum);
    % ���㵼Ƶ����ؾ���
    for PortInd = 1:PortNum
        for DMRSInd1 = 1:DMRSLen
            for DMRSInd2 = 1:DMRSLen
                DeltaF = abs(DMRS_LOCATION(1,DMRSInd2,PortInd) - DMRS_LOCATION(1,DMRSInd1,PortInd))+1;
                DeltaT = abs(DMRS_LOCATION(2,DMRSInd2,PortInd) - DMRS_LOCATION(2,DMRSInd1,PortInd))+1;
                    if DMRS_LOCATION(1,DMRSInd1,PortInd) >= DMRS_LOCATION(1,DMRSInd2,PortInd)
                        Rhh(DMRSInd1,DMRSInd2,PortInd) = RffRtt(DeltaF,DeltaT);
                    else
                        Rhh(DMRSInd1,DMRSInd2,PortInd) = RffRtt(DeltaF,DeltaT)';
                    end
            end
        end
    end
    % ���㵼Ƶ�����ݼ�Ļ���ؾ���
    for PortInd = 1:PortNum
        for DataInd = 1:DataLen
            for DMRSInd = 1:DMRSLen
                DeltaF = abs(DATA_LOCATION(1,DataInd,PortInd) - DMRS_LOCATION(1,DMRSInd,PortInd))+1;
                DeltaT = abs(DATA_LOCATION(2,DataInd,PortInd) - DMRS_LOCATION(2,DMRSInd,PortInd))+1;
                    if DATA_LOCATION(1,DataInd,PortInd) >= DMRS_LOCATION(1,DMRSInd,PortInd)
                        Rdh(DataInd,DMRSInd,PortInd) = RffRtt(DeltaF,DeltaT);
                    else
                        Rdh(DataInd,DMRSInd,PortInd) = RffRtt(DeltaF,DeltaT)';
                    end
            end
        end
    end
end

save('R_hh_dh_viena_DMRS_frontloaded2RB.mat', 'Rhh', 'Rdh','R_hh_PSS');