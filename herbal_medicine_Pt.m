clear
clc
%% 添加工具箱路径
addpath("D:\桌面\VAR_Toolbox_2.0\VAR")
addpath("D:\桌面\VAR_Toolbox_2.0\Auxiliary")
addpath("D:\桌面\VAR_Toolbox_2.0\ExportFig")
addpath("D:\桌面\VAR_Toolbox_2.0\Figure")
addpath("D:\桌面\VAR_Toolbox_2.0\Stats")
addpath("D:\桌面\VAR_Toolbox_2.0\Utils")
tic
% 读取数据
[data,text]=xlsread('D:\桌面\data_log.xlsx','Sheet1');
% 设定滞后阶数
nlags =3;
% 设定是否3含有常数项
det = 1;
[VAR, VARopt] = VARmodel(data,nlags,det);
%% 结构化分析（短期零约束）
% 约束方式
VARopt.ident = 'oir';
%% 识别和脉冲响应估计
VARopt.nsteps = 20;
VARopt.ndraws = 1000 ;
VARopt.pctg   = 68   ;
VARopt.method = 'bs' ;
VARopt.ident  = 'oir';
[INF,SUP,MED,BAR] = VARirband(VAR, VARopt);
% 截取数据
INF_RPI = squeeze(INF(:,1,:));
SUP_RPI = squeeze(SUP(:,1,:));
MED_RPI = squeeze(MED(:,1,:));
%% 画图
figure
set(0,'defaultfigurecolor','w')
names = {'lnRPI对lnRPI的脉冲响应函数图','lnPCM对lnRPI的脉冲响应函数图','lnMT对lnRPI的脉冲响应函数图','lnCPI对InRPI的脉冲响应函数图','lnEV对InRPI的脉冲响应函数图'};
for ii = 1:5
    
    subplot(5,1,ii)
    
    plot(1:20,INF_RPI(:,ii),'--r','Linewidth',3)
    hold on
    plot(1:20,SUP_RPI(:,ii),'--r','Linewidth',3)    
    hold on
    plot(1:20,MED_RPI(:,ii),'b','Linewidth',3) 
    
    hold on
    plot(zeros(20),':k','Linewidth',1)
    
    title(names(ii))
    
    set(gca,'Fontsize',18,'Color','none')
    
    axis tight
    
    
end
%%预测误差方差分解
[INF1,SUP1,MED1,BAR1] = VARfevdband(VAR,VARopt);
% 截取数据
IRinf_OP_FEVD = squeeze(INF1(:,:,1));%期数 变量 冲击 
IRsup_OP_FEVD= squeeze(SUP1(:,:,1));
IRmed_OP_FEVD = squeeze(MED1(:,:,1));
%% 画图
figure
names = {'lnRPI对lnRPI的方差分解图','lnPCM对lnRPI的方差分解图','lnMT对lnRPI的方差分解图','lnCPI对InRPI的方差分解图','lnEV对InRPI的方差分解图'};
for ii = 1:5
    
    subplot(5,1,ii)
    
    plot(1:20,IRmed_OP_FEVD(:,ii),'b','Linewidth',3)%均值
    hold on
    plot(1:20,IRinf_OP_FEVD(:,ii),'--r','Linewidth',3)%虚线上界   
    hold on
    plot(1:20,IRsup_OP_FEVD(:,ii),'--r','Linewidth',3)%虚线下界
    
    hold on
    plot(zeros(20),':k','Linewidth',1)
    
    title(names(ii))
    
    set(gca,'Fontsize',18,'Color','none')
    
    axis tight
    
    
end


%% 历史分解
% Compute IR
[IR, VAR] = VARir(VAR,VARopt);
HD = VARhd(VAR);

HD_OP = squeeze(HD.shock(:,:,1));

mean_data = mean(data,1);

data_adjusted = data - repmat(mean_data,30,1);
%% 画图
figure
tim = 1992:2021;
names = {'中药材价格自身影响冲击','供给冲击','中药材国内需求冲击','通货膨胀冲击','中药材国外需求冲击'};
for ii = 1:5
    
    subplot(5,1,ii)
    bar(tim,HD_OP(:,ii))  
    hold on
    plot(tim,data_adjusted(:,1),'r','Linewidth',2)
    
     

    
    legend('中药材价格冲击解释部分','除均值数据');
    legend('boxoff')
    
    title(names(ii))
    
    set(gca,'Fontsize',18,'Color','none')
    
    axis tight
    
    
end