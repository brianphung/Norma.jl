close all; clear all; 

coords1 = csvread('01-refe.csv'); 
N1 = length(coords1); 
n1 = N1/3; 
x1 = coords1(:,1); 
y1 = coords1(:,2); 
z1 = coords1(:,3);
ind1 = find(x1 == min(x1) & y1 == min(y1));
coords2 = csvread('02-refe.csv'); 
N2 = length(coords2); 
n2 = N2/3; 
x2 = coords2(:,1); 
y2 = coords2(:,2); 
z2 = coords2(:,3);
ind2 = find(x2 == min(x2) & y2 == min(y2));
z = sort(unique([z1;z2])); 
dispz1 = []; veloz1 = []; accez1 = [];
dispz2 = []; veloz2 = []; accez2 = [];
disp_computed = []; velo_computed = []; acce_computed = []; 
disp_exact = []; velo_exact = []; acce_exact = [];
fig = figure();
save_figs = 0;  
ctr = 1; 
for i=0:100:10000
  if (i < 10) 
    disp1_file_name = strcat('01-disp-000', num2str(i), '.csv');
    velo1_file_name = strcat('01-velo-000', num2str(i), '.csv');
    acce1_file_name = strcat('01-acce-000', num2str(i), '.csv');
    time1_file_name = strcat('01-time-000', num2str(i), '.csv');
    disp2_file_name = strcat('02-disp-000', num2str(i), '.csv');
    velo2_file_name = strcat('02-velo-000', num2str(i), '.csv');
    acce2_file_name = strcat('02-acce-000', num2str(i), '.csv');
    time2_file_name = strcat('02-time-000', num2str(i), '.csv');
  elseif (i < 100) 
    disp1_file_name = strcat('01-disp-00', num2str(i), '.csv');
    velo1_file_name = strcat('01-velo-00', num2str(i), '.csv');
    acce1_file_name = strcat('01-acce-00', num2str(i), '.csv');
    time1_file_name = strcat('01-time-00', num2str(i), '.csv');
    disp2_file_name = strcat('02-disp-00', num2str(i), '.csv');
    velo2_file_name = strcat('02-velo-00', num2str(i), '.csv');
    acce2_file_name = strcat('02-acce-00', num2str(i), '.csv');
    time2_file_name = strcat('02-time-00', num2str(i), '.csv');
  elseif (i < 1000) 
    disp1_file_name = strcat('01-disp-0', num2str(i), '.csv');
    velo1_file_name = strcat('01-velo-0', num2str(i), '.csv');
    acce1_file_name = strcat('01-acce-0', num2str(i), '.csv');
    time1_file_name = strcat('01-time-0', num2str(i), '.csv');
    disp2_file_name = strcat('02-disp-0', num2str(i), '.csv');
    velo2_file_name = strcat('02-velo-0', num2str(i), '.csv');
    acce2_file_name = strcat('02-acce-0', num2str(i), '.csv');
    time2_file_name = strcat('02-time-0', num2str(i), '.csv');
  else 
    disp1_file_name = strcat('01-disp-', num2str(i), '.csv');
    velo1_file_name = strcat('01-velo-', num2str(i), '.csv');
    acce1_file_name = strcat('01-acce-', num2str(i), '.csv');
    time1_file_name = strcat('01-time-', num2str(i), '.csv');
    disp2_file_name = strcat('02-disp-', num2str(i), '.csv');
    velo2_file_name = strcat('02-velo-', num2str(i), '.csv');
    acce2_file_name = strcat('02-acce-', num2str(i), '.csv');
    time2_file_name = strcat('02-time-', num2str(i), '.csv');
  end
  d1 = dlmread(disp1_file_name); 
  v1 = dlmread(velo1_file_name); 
  a1 = dlmread(acce1_file_name); 
  t1 = dlmread(time1_file_name); 
  dispz1 = [dispz1, d1(:,3)]; 
  veloz1 = [veloz1, v1(:,3)]; 
  accez1 = [accez1, a1(:,3)]; 
  d2 = dlmread(disp2_file_name); 
  v2 = dlmread(velo2_file_name); 
  a2 = dlmread(acce2_file_name); 
  t2 = dlmread(time2_file_name); 
  dispz2 = [dispz2, d2(:,3)]; 
  veloz2 = [veloz2, v2(:,3)]; 
  accez2 = [accez2, a2(:,3)];
  z1ind1 = z1(ind1); 
  z2ind2 = z2(ind2);
  zz = uniquetol(sort([z1ind1;z2ind2]), 1e-5);
  dz1ind1 = dispz1(ind1,ctr); 
  dz2ind2 = dispz2(ind2,ctr); 
  vz1ind1 = veloz1(ind1,ctr); 
  vz2ind2 = veloz2(ind2,ctr); 
  az1ind1 = accez1(ind1,ctr); 
  az2ind2 = accez2(ind2,ctr); 
  for i = 1:length(zz)
    ii1 = find(z1ind1 == zz(i)); 
    ii2 = find(z2ind2 == zz(i)); 
    dispz_merged(i,1) = 0; 
    veloz_merged(i,1) = 0; 
    accez_merged(i,1) = 0; 
    if length(ii1) > 0 
      dispz_merged(i,1) = dispz_merged(i,1) + dz1ind1(ii1); 
      veloz_merged(i,1) = veloz_merged(i,1) + vz1ind1(ii1); 
      accez_merged(i,1) = accez_merged(i,1) + az1ind1(ii1); 
    end
    if length(ii2) > 0 
      dispz_merged(i,1) = dispz_merged(i,1) + dz2ind2(ii2); 
      veloz_merged(i,1) = veloz_merged(i,1) + vz2ind2(ii2); 
      accez_merged(i,1) = accez_merged(i,1) + az2ind2(ii2); 
    end
    if length(ii1) + length(ii2) > 1 
      dispz_merged(i,1) = dispz_merged(i,1)/2; 
      veloz_merged(i,1) = veloz_merged(i,1)/2; 
      accez_merged(i,1) = accez_merged(i,1)/2; 
    end 
  end
  c = sqrt(1e9/1e3);
  a = 0.001;
  b = 0.0;
  s = 0.02;
  T = 1e-3;
  d_ex = 1/2*a*(exp(-(zz-c*t1-b).^2/2/s^2) + exp(-(zz+c*t1-b).^2/2/s^2))...
         - 1/2*a*(exp(-(zz-c*(T-t1)-b).^2/2/s^2) + exp(-(zz+c*(T-t1)-b).^2/2/s^2));
  v_ex = c/2*a/s^2*((zz-c*t1-b).*exp(-(zz-c*t1-b).^2/2/s^2) - (zz+c*t1-b).*exp(-(zz+c*t1-b).^2/2/s^2))...
          + c/2*a/s^2*((zz-c*(T-t1)-b).*exp(-(zz-c*(T-t1)-b).^2/2/s^2) - ...
          (zz+c*(T-t1)-b).*exp(-(zz+c*(T-t1)-b).^2/2/s^2));
  a_ex = 1/2*a*(-c^2/s^2*exp(-1/2*(zz-c*t1-b).^2/s^2)+1/s^4*c^2*((zz-c*t1-b).^2).*exp(-1/2*(zz-c*t1-b).^2/s^2)-c^2/s^2*exp(-1/2*(zz+c*t1-b).^2/s^2)+1/s^4*c^2*((zz+c*t1-b).^2).*exp(-1/2*(zz+c*t1-b).^2/s^2)) - ...
             1/2*a*(-c^2/s^2*exp(-1/2*(zz-c*(T-t1)-b).^2/s^2)+1/s^4*c^2*((zz-c*(T-t1)-b).^2).*exp(-1/2*(zz-c*(T-t1)-b).^2/s^2)-c^2/s^2*exp(-1/2*(zz+c*(T-t1)-b).^2/s^2)+1/s^4*c^2*((zz+c*(T-t1)-b).^2).*exp(-1/2*(zz+c*(T-t1)-b).^2/s^2));
  disp_computed = [disp_computed, dispz_merged]; 
  velo_computed = [velo_computed, veloz_merged]; 
  acce_computed = [acce_computed, accez_merged]; 
  disp_exact = [disp_exact, d_ex]; 
  velo_exact = [velo_exact, v_ex]; 
  acce_exact = [acce_exact, a_ex]; 

  subplot(3,1,1);
  ax = gca;
  plot(z1(ind1), dispz1(ind1,ctr), '-b');
  hold on; 
  plot(z2(ind2), dispz2(ind2,ctr), '-r');
  %hold on;
  %plot(zz, d_ex, '--c'); 
  xlabel('z'); 
  ylabel('z-disp'); 
  hold on;
  title(['displacement snapshot ', num2str(i+1), ' at time = ', num2str(t1)]);
  axis([min(z) max(z) -0.001 0.001]); 
  ax.NextPlot = 'replaceChildren';
  subplot(3,1,2);
  ax = gca;
  plot(z1(ind1), veloz1(ind1,ctr), '-b');
  hold on; 
  plot(z2(ind2), veloz2(ind2,ctr), '-r');
  %hold on;
  %plot(zz, v_ex, '--c'); 
  xlabel('z'); 
  ylabel('z-velo'); 
  hold on;
  title(['velocity snapshot ', num2str(i+1), ' at time = ', num2str(t1)]);
  axis([min(z) max(z) -3e4*0.001 3e4*0.001]);
  ax.NextPlot = 'replaceChildren';
  subplot(3,1,3);
  ax = gca;
  plot(z1(ind1), accez1(ind1,ctr), '-b');
  hold on; 
  plot(z2(ind2), accez2(ind2,ctr), '-r');
  %hold on;
  %plot(zz, a_ex, '--c'); 
  xlabel('z'); 
  ylabel('z-acce'); 
  title(['acceleration snapshot ', num2str(i+1), ' at time = ', num2str(t1)]);
  axis([min(z) max(z) -2.5e9*0.001 2.5e9*0.001]);
  hold on;
  ax.NextPlot = 'replaceChildren';
  pause(0.5)
  %pause()
  if (save_figs == 1)
    if (ctr < 10)
      filename = strcat('soln_000', num2str(ctr), '.png');
      filename2 = strcat('soln_000', num2str(ctr), '.fig');
    elseif (ctr < 100)
      filename = strcat('soln_00', num2str(ctr), '.png');
      filename2 = strcat('soln_00', num2str(ctr), '.fig');
    elseif (ctr < 1000)
      filename = strcat('soln_0', num2str(ctr), '.png');
      filename2 = strcat('soln_0', num2str(ctr), '.fig');
    else
      filename = strcat('soln_', num2str(ctr), '.png');
      filename2 = strcat('soln_', num2str(ctr), '.fig');
    end
    saveas(fig,filename)
    saveas(fig,filename2)
  end  
  ctr = ctr + 1; 
end

sz = size(disp_exact);
numerator_disp = 0; 
denomenator_disp = 0; 
numerator_velo = 0; 
denomenator_velo = 0; 
numerator_acce = 0; 
denomenator_acce = 0; 
%for i=1:sz(2) 
%  numerator_disp = numerator_disp + norm(disp_computed(:,i) - disp_exact(:,i))^2; 
%  denomenator_disp = denomenator_disp + norm(disp_exact(:,i))^2; 
%  numerator_velo = numerator_velo + norm(velo_computed(:,i) - velo_exact(:,i))^2; 
%  denomenator_velo = denomenator_velo + norm(velo_exact(:,i))^2; 
%  numerator_acce = numerator_acce + norm(acce_computed(:,i) - acce_exact(:,i))^2; 
%  denomenator_acce = denomenator_acce + norm(acce_exact(:,i))^2; 
%end
%dispz_relerr = sqrt(numerator_disp/denomenator_disp); 
%veloz_relerr = sqrt(numerator_velo/denomenator_velo); 
%accez_relerr = sqrt(numerator_acce/denomenator_acce); 

%fprintf('z-disp avg rel error = %e\n', dispz_relerr); 
%fprintf('z-velo avg rel error = %e\n', veloz_relerr); 
%fprintf('z-acce avg rel error = %e\n', accez_relerr); 
