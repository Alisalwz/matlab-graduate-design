%% ��������
% MMSE���ϼ��
%% �������
% DataSymOut:���յ��������� NumRec*Len
% HEst�����Ƴ����ŵ� NumRec* ��NumTra*Len��
% SnrLinear�����������ֵ
% NumTra�����Ͷ�������
%% �������
% MMSEOut��������������
% MMSESinr���������Ÿ����
%% Modify history
% 2017/6/6 created by Bu Shuqing
%% code
function [ MMSEOut, MMSESinr ] = MMSE_detector_MIMO( DataSymOut, HEst, SnrLinear, NumTra)
n_power=1/SnrLinear;                          % ��������
Len = size(DataSymOut,2);
Ir=eye(NumTra);
MMSEOut = zeros(NumTra,Len);                  % ������������
MMSESinr = zeros(NumTra,Len);                 % �������Ÿ����
    for I_s = 1 : Len
        H = HEst(:,(I_s:Len:NumTra*Len));     % NumRec* NumTra
        MMSEMat=pinv(H'*H+n_power*Ir)*H';
        NorMat = zeros(NumTra,NumTra);
        for TraInd = 1:NumTra
            NorMat(TraInd,TraInd) = 1 / (MMSEMat(TraInd,:) * H(:,TraInd));    
        end            
        NorMMSEMat = NorMat * MMSEMat;            
        MMSEOut(:,I_s) = NorMMSEMat * DataSymOut(:,I_s); 
        % ���SINR
        temp_u = zeros(NumTra,NumTra);         %����
        temp_dl = zeros(NumTra,NumTra);        %����ĸ
        temp_dr = zeros(NumTra,NumTra);        %�Ҳ��ĸ
        for TraInd = 1:NumTra
           temp_u(TraInd)=(MMSEMat(TraInd,:)*H(:,TraInd)) * (MMSEMat(TraInd,:)*H(:,TraInd))';
           temp_dl(TraInd) = (MMSEMat(TraInd,:) * H) * (MMSEMat(TraInd,:) * H)'-temp_u(TraInd); 
           temp_dr(TraInd) = MMSEMat(TraInd,:)*MMSEMat(TraInd,:)'*n_power; 
           MMSESinr(TraInd ,I_s) = temp_u(TraInd)/(temp_dl(TraInd)+temp_dr(TraInd));                
        end        
    end
end

