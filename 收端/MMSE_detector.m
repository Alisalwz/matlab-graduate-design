function [ data , sinr] = MMSE_detector( indata, H )
%MMSE_DETECTOR �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
    sinr = 20;
    data = indata./H;

end

