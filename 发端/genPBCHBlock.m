function [ out1,out21,out22,out3 ] = genPBCHBlock( PBCHData,NID )
%GENPBCHBLOCK �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
global DMRS;
out1 = zeros(1,240);
out3 = zeros(1,240);
out21 = zeros(1,48);
out22 = zeros(1,48);
DMRS_v = mod(NID,4);
if length(PBCHData) ~= 432 || DMRS_v > 3
    error('PBCH���ݳ��Ȳ���ȷ')
else
    index_1_3 = [0:239] + 1; %�õ������ز��±�
    index_2 = [0:47] + 1;

    DMRS_index1_3 = [0:4:236] + 1 + DMRS_v; %DMRS�����ز��±�
    DMRS_index2 = [0:4:44] + 1 + DMRS_v;
    
    %PBCH���ݷ���
    data1 = PBCHData(1:180);
    data21 = PBCHData(181:216);
    data22 = PBCHData(217:252);
    data3 = PBCHData(253:end);
   %����PBCH���ݲ������ز��±�
   for i = 1:length(DMRS_index1_3)
       locate = find(index_1_3 == DMRS_index1_3(i));
       if(~isempty(locate))
           index_1_3(locate) = [];
       end
   end
   for i = 1:length(DMRS_index2)
       locate = find(index_2 == DMRS_index2(i));
       if(~isempty(locate))
           index_2(locate) = [];
       end
   end
   %����dmrs
   for i = 1:144
       dmrsData(i) = dmrs(i-1, 0, NID, 0 );
   end
   DMRS = dmrsData;
   %��PBCH���ݷŵ���Ӧ�ӵ��ز�λ��
   out1(index_1_3) = data1;
   out1(DMRS_index1_3) = dmrsData(1:60);
   out21(index_2) = data21;
   out21(DMRS_index2) = dmrsData(61:72);
   out22(index_2) = data22;
   out22(DMRS_index2) = dmrsData(73:84);
   out3(index_1_3) = data3;
   out3(DMRS_index1_3) = dmrsData(85:144);
end

end

