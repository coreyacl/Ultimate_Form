% close all
%in feet 
distances = [0 0 0 0 180 200 210 205 198 187 171 171 177 170 207 160 101 125 113 117 88 124 90 105 109];

data = csvread('logger/Arm_Data.csv',3,0);
titles = readtable('logger/Arm_Data.csv');
titles = cellstr(table2cell(titles(1,2:4:end)));

%time shift to lineup throw from arm data and disc data
starts = [5.5 8.3 0 -9.1 -3.3 2 1.3 5.78 5.3 6.1 2.5 9 1.5 1.5 30.2 8.7 3.5 35.1 17.3 13.65];%index 1 = take 6
maxA = [];
%n=22,24 are weird
for n = [6:1:7 9:1:25] %missing data for 8
    s = strcat('disc/take',num2str(n),'.csv');
    a = csvread(s,0,1);
    accel1 = a(1:2:end,:)';
    accel11 = vecnorm(accel1);
    gyro = a(2:2:end,:);
    t = (1:1:length(accel1))/10-starts(n-5);
    
    figure
    subplot(3,1,1);
    plot(t,accel1);title("Disc Accelerometer");xlabel("time (s)");ylabel("Acceleration (g)");
    legend('x','y','z','location','northwest');
    
    subplot(3,1,2);
%     plot(t,gyro);title("Gyroscope");xlabel("time (s)");ylabel("Acceleration (g)");   
    
   c = n-5;hold on
   time = nonzeros(data(:,(c*4-3)));
   accel = data(1:length(time),(c*4-2):c*4)./(9.8);
   accel2 = vecnorm(accel');
   plot(time,accel,'--');
   title("Arm Accelerometer");xlabel("time (s)");ylabel("Acceleration (g)");
   legend('x','y','z','location','northwest');
   
   subplot(3,1,3);
   plot(t,accel1,'b');hold on
   plot(time,accel,'r--');
%    maxA(n,1) = max(accel1); %disc
%    maxA(n,2) = max(accel);  %arm
   xlabel('Time (s)');ylabel('Acceleration (g)');title(strcat('take',num2str(n),'-',titles(c)));
   legend('disc','','','','','arm','location','northwest');%ylim([0 12])
   if t(end) > time(end,1)
       xlim([0 time(end,1)]);%xlim([0 t(end)]);
   else
       xlim([0 t(end)]);
   end
   
%    pause(1);close all
end
% figure
% plot(maxA(:,2),distances,'o');xlabel('Acceleration (g)');ylabel('Distance Traveled (ft)');
%% FFFTFFFTFFT Transformation
distances = [0 0 0 0 180 200 210 205 198 187 171 171 177 170 207 160 101 125 113 117 88 124 90 105 109];
data = csvread('logger/Arm_Data.csv',3,0);
titles = readtable('logger/Arm_Data.csv');
titles = cellstr(table2cell(titles(1,2:4:end)));
% angs = zeros(25,1);
% maxA = zeros(25,1);
% grav = [0 0 -0.9680];
for n = [6:1:7 9:1:25] %missing data for 8
    c = n-5;
    s = strcat('disc/take',num2str(n),'.csv');
    a = csvread(s,0,1);
%     accel1 = a(1:2:end,:);
%     accelMag = vecnorm(accel1');
    gyro = a(2:2:end,:);
    t = (1:1:length(gyro))/10;%-starts(n-5);
%     figure
%     grav = [0 0 mean(accel1(19:24,3))]
    Fs = 10;
    N = length(gyro);
    bigx = fftshift(fft(gyro));
    frequencies_shifted = linspace(-pi, pi-2/N*pi, N) + pi/N*mod(N,2);
    x1 = frequencies_shifted*Fs;
    figure
    plot(x1,abs(bigx));xlabel('Frequencies (Hz)');ylabel('Magnitude');hold on
%     title('Fourier Transformation of Disc');
    title(strcat('take',num2str(n),'-',titles(c)));
    [val,ind] = max(abs(bigx));
    val = max(val);
    plot([-5 -5],[0 val],'r');
    plot([5 5],[0 val],'r');
    legend('x','y','z','location','northwest');
%    time = nonzeros(data(:,(c*4-3)));
%     accel1 = data(1:length(time),(c*4-2):c*4)./(9.8);
%     grav = accel1(50,:);
%     accelMag = vecnorm(accel1');
%     [val,ind] = max(accelMag);
%     maxA(n,1) = val; %disc
%     A = accel1(ind-1,:)/norm(accel1(ind,:));
%     B = grav/norm(grav);
%     angs(n) = atan2d(norm(cross(A,B)),dot(A,B));

%     subplot(2,1,1);
%     plot(t,accel1,'b');title("Accelerometer");xlabel("time (s)");ylabel("Acceleration (g)");hold on
%     plot(t,accel1);title("Accelerometer");xlabel("time (s)");ylabel("Acceleration (g)");hold on
%     subplot(2,1,2);
%     plot(t,gyro);title("Gyroscope");xlabel("time (s)");ylabel("Acceleration (g)");   
%     legend('Norm of Acceleration','Angular V. (X)','Angular V. (Y)','Angular V. (Z)','location','northwest');
%     title(strcat('take',num2str(n),'-',titles(c)));
%     pause(1);close all
end
%%
figure
scatter3(maxA,angs,distances,'filled');
zlabel('Distance thrown (ft)');ylabel('Angle of attack (deg)');xlabel('Acceleration (g)');
%%
figure
yyaxis left
plot(distances,angs,'o');ylim([20 80]);
ylabel('Angle of attack (deg)');xlabel('Distance thrown (ft)')
yyaxis right
plot(distances,maxA,'o');ylim([6 10]);
ylabel('Acceleration (g)');
title('Arm Data')


%% Original sample logger data. No distance recorded
for n = [2,3,4]
    s = strcat('logger/take',num2str(n),'.csv');
    r = csvread(s,1,0);
    a = r(:,2:4);
    t = r(:,1);
    figure
    plot(t,a);title("Accelerometer");xlabel("time (s)");ylabel("Acceleration (m/s^2)"); 
end
%% For reading from large .csv with the rest of the takes

for n = [6:1:28]
   figure
   c = n-5;
   time = nonzeros(data(:,(c*4-3)));
   accel = data(1:length(time),(c*4-2):c*4);
   plot(time,accel);
   xlabel('Time (s)');ylabel('Acceleration m/s^2');title(strcat('take',num2str(n),'-',titles(c)));
   
end

