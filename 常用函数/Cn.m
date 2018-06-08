function [ cn ] = Cn( init , L)
%CN �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
%  ���� init Ϊ38.211��5.2.1�����Cinit����һ������
%  L ����Ҫ�����г���
if init < 0
    error('Cnģ�����벻��ȷ')
else
   Nc = 1600;
   arr = dec2bin(init) - '0';
   len  = length(arr);
   derlen = 31 - len;
   x1_reg = [zeros(1,30) 1];
   x2_reg = [zeros(1,derlen) arr];
   x1_gen = [1 zeros(1,27) 1 0 0 1];
   x2_gen = [1 zeros(1,27) 1 1 1 1];
   out1 = 0;
   out2 = 0;
   for i = 1:Nc
       x1 = mod(x1_reg(31)+x1_reg(28),2);
       x1_reg = [x1 x1_reg(:,1:30)];
       x2 = mod(x2_reg(31)+x2_reg(30)+x2_reg(29)+x2_reg(28),2);
       x2_reg = [x2 x2_reg(:,1:30)];
   end
   
   for j = 0:L
       out1 = x1_reg(31);
       x1 = mod(x1_reg(31)+x1_reg(28),2);
       x1_reg = [x1 x1_reg(:,1:30)];
       out2 = x2_reg(31);
       x2 = mod(x2_reg(31)+x2_reg(30)+x2_reg(29)+x2_reg(28),2);
       x2_reg = [x2 x2_reg(:,1:30)];
   end
   cn = mod(out1+out2,2);
end
end

