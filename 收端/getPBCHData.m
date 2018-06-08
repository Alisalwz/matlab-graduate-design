function [ data, dmrs ] = getPBCHData( PBCHSymbols, nid)
%GETPBCHDATA �˴���ʾ�йش˺�����ժҪ
%  ssBlock��һ��ʱ���źţ���һ������ûһ�д������ز���ÿһ�д���һ������
DMRS_v = mod(nid,4);
len = length(PBCHSymbols);
data = [PBCHSymbols(1:288) PBCHSymbols(len-288+1:len)];

%����DMRSλ��
DMRS_index = [1:4:576] + DMRS_v;
dmrs = data(DMRS_index);
data(DMRS_index) = [];
end

