function [ RSMapMatrix ] = Map_RS( RBNum,DMRS_FREQUENCY,DMRS_TIME )
%% �������ܣ�
% ����ο��źŵ���Դӳ����󣬾���ÿ�д���Ƶ���϶�Ӧ��1�����ز���ÿ�д���ʱ���϶�Ӧ��1�����ţ���Ӧ����Ԫ�� 1: ����, 2: DMRS,
%% ���������
% RBNum ������������RB����
% DMRS_FREQUENCY��DMRS���ڵ�Ƶ��λ�ã�1��RB��
% DMRS_TIME��DMRS���ڵ�ʱ��λ�ã�1��RB��
%% ���������
% RSMapMatrix����Դӳ�����
%% Modify history
% 2017/10/28 created by Liu Chunhua 
%% code

RSMapMatrix = [];
global SUBCARRIER_PER_RB;
global SYMBOL_PER_SUBFRAME;
global PDCCH_LENTH;
% REӳ��
RSMapMatrixRB = ones(SUBCARRIER_PER_RB,SYMBOL_PER_SUBFRAME);
% ������Դӳ��
RSMapMatrixRB(:,1:PDCCH_LENTH)=0;
% �ο��ź�ӳ��
for i=1:length(DMRS_TIME)
    RSMapMatrixRB(DMRS_FREQUENCY,DMRS_TIME(i))=2;
end
% ��RB�������
for ii=1:RBNum
    RSMapMatrix=[RSMapMatrix;RSMapMatrixRB];
end

end

