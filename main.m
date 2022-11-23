clc
% clear all
close('all')

img = imread('Obraz1.jpg');
User0fixations = readtable('User 0_fixations.csv');

% ---------------Śledzenie ruchu ----------------------

fix_l = table2array(User0fixations(:,6));
fix_r = table2array(User0fixations(:,7));
time = table2array(User0fixations(:,4));

start = 0;
for i =1:height(time)
    if time(i,1) > 6
        start = i;

        break
    else
        continue
    end
end

stop = 0;
for i =1:height(time)
    if time(i,1) > 16
        stop = i;

        break
    else
        continue
    end
end

% obraz1.jpg 1365 1024

fix_l = fix_l * 1365;
fix_r = fix_r * 1024;


figure()
imshow(img)
hold on;
plot(fix_l(start:stop), fix_r(start:stop),'b->','LineWidth',2);
hold on;


for ii = 1:height(fix_l(start:stop))
    
    t = text(fix_l(start+ii,1),fix_r(start+ii,1),num2str(ii));
    t(1).Color = 'white';
    t(1).FontSize = 20;
    hold on;
end

% ----------------------MAPA FIKSACJI -----------------

time = table2array(User0fixations(start:stop, 9));
ids = table2array(User0fixations(start:stop, 10));



figure()
imshow(img);
hold on;
plot(fix_l(start:stop), fix_r(start:stop),'b-','LineWidth',2);
hold on;

for i=1:height(fix_l(start:stop))
    x = fix_l(start+i-1);
    y = fix_r(start+i-1);
    r = time(i) * 40;
    ang=0:0.01:2*pi;
    xp=r*cos(ang);
    yp=r*sin(ang);
    plot(x+xp,y+yp, '.r');
    text(x, y, num2str(i), 'FontSize',15,'Color', 'w', 'VerticalAlignment','middle','HorizontalAlignment','center');
end 

%-------------------MAPA CIEPLNA--------------------------


time_var = [min(time) mean(time) max(time)];
Heat_map = uint8(zeros(height(img),width(img),1));
temp = uint8(zeros(height(img),width(img),1));


for j = 1:size(fix_l(start:stop),1)
    a = floor((time(j)*255)/time_var(3));
    color_new = [a,a,a];
    Heat_map  = Heat_map + imgaussfilt(insertShape(temp,'FilledCircle',[x(j) y(j) 20],'Color', color_new,'Opacity',1.0),10);
end

Heat_map = double(Heat_map(:,:,1));
Heat_map = Heat_map/max(max(Heat_map));

alpha = Heat_map;
alpha2 = Heat_map;
alpha2(Heat_map>0)=1;
Heat_map_2 = Heat_map.*255;
Heat_map_2 = floor(Heat_map_2);
    
Heat_map_2 = uint8(Heat_map_2);
rgbImage = ind2rgb(Heat_map_2, jet(256));

beta = ones(size(alpha2));
beta = beta-alpha2;
BG2 = (double(img)./255);

f = rgbImage .* alpha2;
b = BG2 .* beta;
rgbImage2 = f + b;
imtool(rgbImage2);

