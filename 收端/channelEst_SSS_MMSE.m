function [ ch_MMSE ] = channelEst_SSS_MMSE( ch_LS, R_hh, SnrLinear )
%CHANNELEST_SSS_MMSE �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
    %����beita
    %���㷽�� beita=(�������ƽ���ľ�ֵ)*(�����㵹����ƽ���ľ�ֵ)
    %��beita=(sum(abs(constel_diagram).^2)/64)*(sum(abs(1./constel_diagram).^2)/64)
    global MODULATION;
    switch (MODULATION)
        case {2}                               % QPSKΪ2
            beita=1;
        case {4}                               % 16QAMΪ4
            beita=17/9;
        case {6}                               % 64QAMΪ6
            beita=2.6854;            
    end
    R_hh_pilot = R_hh / (R_hh+beita/SnrLinear*eye(length(R_hh)));

    ch_MMSE = R_hh_pilot*ch_LS.';

end

