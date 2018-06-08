%% �������ܣ�
% ���ݹ��ŵ�
%% �������
% SignalIn����������
% PreInterfere��������һ�����ݰ���ǰ�����
% H���ŵ�����
%% �������
% SignalOut���������
% SignalInterfere������һ�����ݰ���ǰ�����
%% Modify history
% 2018/1/18 created by Liu Chunhua 
%% code
function [SignalOut, SignalInterfere] = Pass_Channel(SignalIn,PreInterfere,H)
global UE_ANT_NUM;
global NB_ANT_NUM;
global DELAY_OUT;
global MAX_DELAY;

MulPath  = size(H,3);
% ���������
N = size(SignalIn,2);
% ǰ����ŵ���
PreSeqNum = min(MAX_DELAY,size(PreInterfere,2));
%% �źŹ��ŵ�
SignalTemp = zeros(UE_ANT_NUM*NB_ANT_NUM,N+MAX_DELAY);
for u=1:UE_ANT_NUM %ע�����ǽ��ն�����
    for s=1:NB_ANT_NUM %��������
        for n=1:MulPath
            DelayAdd = DELAY_OUT(n);
            HTemp=H(u,s,n,:);
%             SignalTemp((u-1)*NB_ANT_NUM+s,(DelayAdd+1):(DelayAdd+N)) = SignalTemp((u-1)*NB_ANT_NUM+s,(DelayAdd+1):(DelayAdd+N)) ...
%                 +SignalIn(s,:).*HTemp;
            SignalTemp((u-1)*NB_ANT_NUM+s,(DelayAdd+1):(DelayAdd+N)) = SignalTemp((u-1)*NB_ANT_NUM+s,(DelayAdd+1):((DelayAdd+N))) ...
                +SignalIn(s,:).*HTemp(1,(DelayAdd+1):(DelayAdd+N));
        end
    end
end
%% ����ǰ�����
for PathInd = 1:UE_ANT_NUM*NB_ANT_NUM
    SignalTemp(PathInd,1:PreSeqNum) = SignalTemp(PathInd,1:PreSeqNum)+PreInterfere(PathInd,1:PreSeqNum);
end
%% ����ź�
SignalOut = SignalTemp(:,1:N);
SignalInterfere = SignalTemp(:,N+1:N+PreSeqNum);
end
