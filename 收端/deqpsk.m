function [ outdata ] = deqpsk( indata )
%DEQPSK �ն˽���qpsk�����ģ��
%   ����һ���������飬ÿ�����Ӧ���������Ʊ��أ�������鳤��������Ķ���
    realdata = real(indata);
    imagdata = imag(indata);
    outdata = [];
%     figure(1)
%     plot(realdata,imagdata,'ro');
%     axis([-1.5 1.5 -1.5 1.5]);
%     grid on;
    
    len = length(indata);
    for i = 1:len
        if realdata(i)>0 && imagdata(i)>0
            outdata = [outdata,[0 0]];
        elseif realdata(i)>0 && imagdata(i)<0
            outdata = [outdata, [0 1]];
        elseif realdata(i) <0 && imagdata(i)<0
            outdata = [outdata, [1 1]];
        else
            outdata = [outdata, [1 0]];
        end
    end
end

