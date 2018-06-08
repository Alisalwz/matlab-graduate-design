%% �������ܣ�
% �����ŵ�����
%% ���������
% PilotSymOut���ο��ź�
% R_dh�������뵼Ƶ���ز���Ļ���ؾ���
% R_hh����Ƶ���ز��������ؾ���
% SnrLinear�����������ֵ
%% �������
% HDataMMSE�����Ƴ�������λ�ô��ŵ�
%% Modify history
% 2017/6/5 created by Mao Zhendong
% 2017/10/30 modified by Liu Chunhua
%% code
function HDataMMSE = Channel_estimation(PilotSymOut, R_dh,R_hh,SnrLinear)

    %����beita
    %���㷽�� beita=(�������ƽ���ľ�ֵ)*(�����㵹����ƽ���ľ�ֵ)
    %��beita=(sum(abs(constel_diagram).^2)/64)*(sum(abs(1./constel_diagram).^2)/64)
%     global MODULATION;
%     switch (MODULATION)
%         case {2}                               % QPSKΪ2
%             beita=1;
%         case {4}                               % 16QAMΪ4
%             beita=17/9;
%         case {6}                               % 64QAMΪ6
%             beita=2.6854;            
%     end
%     R_hh_pilot = R_hh / (R_hh+beita/SnrLinear*eye(length(R_hh)));
    R_hh_data = R_dh / (R_hh+1/SnrLinear*eye(length(R_hh)));

    HLS = PilotSymOut.';                       % LS���Ƴ���DMRS���ŵ�
%     HPilotMMSE = R_hh_pilot * HLS;             % LMMSE���Ƴ���DMRS���ŵ�
    HDataMMSE = (R_hh_data * HLS).';    % LMMSE���Ƴ�������λ�ô��ŵ�
    
    
