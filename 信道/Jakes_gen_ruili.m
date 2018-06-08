function [h]=Jakes_gen_ruili(v,fc,Ts)
%����[h]=myjakesmodel(v,t,fc,k)��
%�ó������øĽ���jakesģ��������������ƽ̹������˥���ŵ�
%Yahong R.Zheng and Chengshan Xiao "Improved Models for
%the Generation of Multiple Uncorrelated Rayleigh Fading Waveforms"
%IEEE Commu letters, Vol.6, NO.6, JUNE 2002
%�������˵����
%  fc���ز�Ƶ�� ��λHz
%  v:�ƶ�̨�ٶ�  ��λm/s
%  t :�ŵ�����ʱ��  ��λs
%  seed: ����˥������������
%  hΪ����������ŵ���������һ��ʱ�亯��������
%���ߣ�¦�Ŀ�   ���ڣ�05.3.13
%��Ų������ٶȼ�����
c=3*10^8;
%��������Ƶ��
wm=fc*v/c;
h = rayleighchan(Ts,wm);