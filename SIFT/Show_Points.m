%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Show_Points(im1,im2,loc1,loc2,cor1,cor2)

uni1=loc1(:,[1 2 3 4 5]);
[~,i,~]=unique(uni1,'rows','first');
loc1=loc1(sort(i)',:);
cor1_x=loc1(:,2);cor1_y=loc1(:,1);
%cor_x1=loc1(point1,1);cor_y1=loc1(point1,2);
button1=figure; colormap('gray'); imagesc(im1);
title(['Reference image ',num2str(size(cor1_x,1)),' points']);hold on;
scatter(cor1_x,cor1_y,'r+');hold on;%scatter可用于描绘散点图
str = ['.\save_image\','Reference image detected points','.jpg'];
saveas(button1,str);

uni1=loc2(:,[1 2 3 4 5]);
[~,i,~]=unique(uni1,'rows','first');
loc2=loc2(sort(i)',:);
cor2_x=loc2(:,2);cor2_y=loc2(:,1);
%cor_x2=loc2(point2,1);cor_y2=loc2(point2,2);
button2=figure; colormap('gray'); imagesc(im2);
title(['Image to be registered ',num2str(size(cor2_x,1)),' points']);hold on;
scatter(cor2_x,cor2_y,'r+');hold on;
str = ['.\save_image\','Image to be registered detected points','.jpg'];
saveas(button2,str);

cor1_x=cor1(:,1);cor1_y=cor1(:,2);point2=cor1(:,7);
%cor_x1=loc1(point1,1);cor_y1=loc1(point1,2);
button3=figure; colormap('gray');imagesc(im1);
title(['Reference image ',num2str(size(cor1_x,1)),' points']);hold on;
scatter(cor1_x,cor1_y,'r');hold on;%scatter可用于描绘散点图
for i=1:size(point2,1)
text(cor1_x(i),cor1_y(i),num2str(point2(i)),'color','y');
end
str = ['.\save_image\','Reference image matched points','.jpg'];
saveas(button3,str);

cor2_x=cor2(:,1);cor2_y=cor2(:,2);
%cor_x2=loc2(point2,1);cor_y2=loc2(point2,2);
button4=figure; colormap('gray');imagesc(im2);
title(['Image to be registered ',num2str(size(cor2_x,1)),' points']);hold on;
scatter(cor2_x,cor2_y,'r');hold on;
for i=1:size(point2,1)
text(cor2_x(i),cor2_y(i),num2str(point2(i)),'color','y');
end
str = ['.\save_image\','Image to be registered matched points','.jpg'];
saveas(button4,str);