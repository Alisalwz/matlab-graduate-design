function [ scrambled_bit ] = scramble( data, L, Ncell)
%SCRAMBLE �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
    A = length(data);
%     �õ���8λ��Ϣ
    bit8 = data(:,A-7:A);
    sfn = bit8(:,1:4);
    hrf = bit8(5);
    Lssb = bit8(:,6:8);
    if L == 4 || L == 8
        M = A -3;
    elseif L == 64
        M = A -6;
    else
        error('����ը��')
    end
    
    if sfn(3) == 0 && sfn(2) ==0
        v = 0;
    elseif sfn(3) == 0 && sfn(2) ==1
        v = 1;
    elseif sfn(3) == 1 && sfn(2) ==0
        v = 2;
    elseif sfn(3) == 1 && sfn(2) ==1
        v = 3;
    else
        error('SFNը��')
    end
%    ��ʼ��sn
    s = [];

    for i = 1:A
        if i >= A-7 && i <= A
            s(i) = 0;
        else
            s(i) = Cn(Ncell,i+v*M-1);
        end
    end
    for j = 1:A
        result(j) = mod(s(j)+data(j),2);
    end
    scrambled_bit = result;
end

