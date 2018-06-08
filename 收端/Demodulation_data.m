%% �������ܣ�
% ����������ݽ����ض�ģʽ�Ľ���������ƣ���ѡ��ģʽ��1��BPSK��2��QPSK��4��16QAM��6��64QAM
%% ���������
% data_in�������������
% SnrLinearMMSE���ŵ�����õ��������ŵ������������
%% �������
% DeQamOut�����ƺ��������
%% Modify history
% 2017/6/5 created by Mao Zhendong
% 2017/10/30 modified by Liu Chunhua
%% code
function  DeQamOut = Demodulation_data(data_in, SnrLinearMMSE)   
    global MODULATION;
    len_input=length(data_in);
    h = ones(1,len_input);
    switch (MODULATION)                            % 1��BPSK��2��QPSK��4��16QAM��6��64QAM
   %% QPSK
    case 2                                       
        n_power=1./SnrLinearMMSE;       
       
        temp_1=real(data_in)>0;
        temp_2=2*temp_1-1;                % �����λ��LLR��Ϣ
        s0_L=(temp_2+1i)*sqrt(2)/2;
        s1_L=(temp_2-1i)*sqrt(2)/2;
       
        d0_L=abs(data_in-s0_L);           % �����źŵ����׼�ź�������֮��ľ���
        d1_L=abs(data_in-s1_L);
        
        llr_L=1.*(d1_L.^2-d0_L.^2)./(n_power.*(1./((abs(h)).^2)));  % ������Ȼ����Ϣllr
        
        temp_1=imag(data_in)>0;
        temp_2=2*temp_1-1;                % �����λ��LLR��Ϣ
        s0_H=(1+1i*temp_2)*sqrt(2)/2;
        s1_H=(-1+1i*temp_2)*sqrt(2)/2;
        
       d0_H=abs(data_in-s0_H);           % �����źŵ����׼�ź�������֮��ľ���
       d1_H=abs(data_in-s1_H);      
       
       llr_H=1.*(d1_H.^2-d0_H.^2)./(n_power.*(1./((abs(h)).^2)));     % ������Ȼ����Ϣllr
   
       DeQamOut = zeros(1,2*len_input);
       for I=1:len_input
           DeQamOut(2*I-1:2*I)=[-llr_L(I),-llr_H(I)];                  % ���ߵ�λ�����������������Ȼ������ 
       end
   %% 16QAM
    case 4                                            
        const_16qam=4;               %16qam���Ŷ�Ӧ�Ķ����Ʊ�����
        %�Զ����Ʊ���������ʾ����16qam����
        %����16qam��Ӧ����λ0��1����Ӧ����λΪ1��0�ķ��ŵľ��룬�����õı���������λ��
        const_num=[1 2 3 4 5 6 7 8];
        %����1/2/3/4λ����ʱ������ڱ��������λ�õ�ƫ�ʮ���Ʊ�ʾ��
        const_num_1=[8 8 8 8 8 8 8 8 ;4 4 4 4 8 8 8 8;2 2 4 4 6 6 8 8;1 2 3 4 5 6 7 8];
        %����ͼ��
        constel_diagram=[sqrt(2)/2+1i*sqrt(2)/2, 1i*1.5*sqrt(2)+sqrt(2)/2, 1i*sqrt(2)/2+1.5*sqrt(2), 1.5*sqrt(2)+1i*1.5*sqrt(2),...       % ��һ����
                         sqrt(2)/2-1i*sqrt(2)/2, -1i*1.5*sqrt(2)+sqrt(2)/2, -1i*sqrt(2)/2+1.5*sqrt(2), 1.5*sqrt(2)-1i*1.5*sqrt(2),...     % ��������
                        -sqrt(2)/2+1i*sqrt(2)/2,-sqrt(2)/2+1i*1.5*sqrt(2),-1.5*sqrt(2)+1i*sqrt(2)/2,-1.5*sqrt(2)+1i*1.5*sqrt(2),...       % �ڶ�����
                        -sqrt(2)/2-1i*sqrt(2)/2,-sqrt(2)/2-1i*1.5*sqrt(2),-1.5*sqrt(2)-1i*sqrt(2)/2,-1.5*sqrt(2)-1i*1.5*sqrt(2)]/sqrt(5); % ��������
        
        h_square=abs(h).^2;                                                  % �õ��ŵ�����ֵ��ƽ��
        DeQamOut=zeros(1,const_16qam*len_input);                             % �洢��Ȼ����Ϣ
        %�����źŵ������������ӳ�����
        temp=[abs(data_in-constel_diagram(1)),abs(data_in-constel_diagram(2)),abs(data_in-constel_diagram(3)),abs(data_in-constel_diagram(4)),abs(data_in-constel_diagram(5)),abs(data_in-constel_diagram(6)),...
            abs(data_in-constel_diagram(7)),abs(data_in-constel_diagram(8)),abs(data_in-constel_diagram(9)),abs(data_in-constel_diagram(10)),abs(data_in-constel_diagram(11)),abs(data_in-constel_diagram(12)),...
            abs(data_in-constel_diagram(13)),abs(data_in-constel_diagram(14)),abs(data_in-constel_diagram(15)),abs(data_in-constel_diagram(16))].^2;
        % �����Ǽ��������Ϣ���ص���Ȼ����Ϣllr
        for m=1:len_input
            temp2=temp(m:len_input:2^const_16qam*len_input);
            for n=1:const_16qam               
                pad_num_1=const_num+const_num_1(n,:);
                dist_square_1=min(temp2(pad_num_1));                        %�����nλ����Ϊ1������ͼ���������������С����
                
                pad_num_0=const_num+const_num_1(n,:)-2^(const_16qam-n);     % �����nλ����Ϊ0������ͼ���������������С����
                dist_square_0=min(temp2(pad_num_0));
                DeQamOut(const_16qam*(m-1)+n)=h_square(m)*(dist_square_1-dist_square_0)*SnrLinearMMSE(m);  % �õ���Ȼ����Ϣ
            end
        end
   %% 64QAM
    case 6                                
        SN_MMSE_dB=10*log10(SnrLinearMMSE);
            for I_deqam=1:len_input
                DeQamOut((6*I_deqam-5):6*I_deqam)=deqam64(real(data_in(I_deqam)),imag(data_in(I_deqam)),real(h(I_deqam)),imag(h(I_deqam)), SN_MMSE_dB(I_deqam));
            end 
    otherwise
        disp('Error! Please input again');        
    end
end