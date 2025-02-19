%Initialize SCOPE

SCOPE


NwlTt                           =   length(rad.Lot_);

%%
meteo.Ta  = 10;
meteo.Rin = 900;
meteo.Rli = 400;
SCOPE_run

figure('Position',[20 20 1024 800])
plot(thermal.Ts(1),-1,'rd',thermal.Ts(2),-1,'or',thermal.Tch,canopy.x,'>g',permute(mean(mean(thermal.Tcu,1),2),[3 1 2]),canopy.x,'*g',meteo.Ta,0.1,'bo'); 

% hold on
% meteo.Rin = 100;
% SCOPE_run

% plot(thermal.Ts(1),-1,'rd',thermal.Ts(2),-1,'or',thermal.Tch,canopy.x,'>g',permute(mean(mean(thermal.Tcu,1),2),[3 1 2]),canopy.x,'*g',meteo.Ta,0.1,'bo'); 
legend('Tsh','Tsu','Tch','Tsu','Ta')
title('Temperature profile for different components')

%%
varnames                            =   {'Cab','Cw','Cca','Cdm','Cs','N','LAI','rho_thermal','tau_thermal'};
Nvar                                =   length(varnames);

LAI                                 =   linspace(0.01,9,11);
LAI                                 =   logspace(log10(0.01),log10(5),10);
Rin                                 =   linspace(50,900,6);
Rli                                 =   linspace(50,600,6);

% individual run for different prospect parameters
S_Lot_                              =   zeros(NwlTt,Nvar,length(LAI), length(Rin))*NaN;
S_Ts                                =   zeros(2,Nvar,length(LAI), length(Rin))*NaN;
[S_Tch,S_Tcu]                       =   deal(zeros(canopy.nlayers,Nvar,length(LAI), length(Rin))*NaN);

for iRin = 1:length(Rin)
    meteo.Rin                       =   Rin(iRin);
%     legendstr{iRin}                 =   sprintf('Rin = % 3.1fW/m2',Rin(iRin));
    for ilai = 1:length(LAI)
        % change LAI
        canopy.LAI                  =   LAI(ilai);
        leafbio.LAI                 =   LAI(ilai);

        % reference run
        leafbio_ref                 =   leafbio;
        canopy_ref                  =   canopy;
        SCOPE_run
        Lot_ref_                    =   rad.Lot_;
        Ts_ref                      =   thermal.Ts;
        Tch_ref                     =   thermal.Tch;
        Tcu_ref                     =   permute(mean(mean(thermal.Tcu,1),2),[3 1 2]);


        for j = 1:Nvar
            varname                 =   varnames{j};

            % reset variables
            leafbio                 =   leafbio_ref;
            leafbio.(varname)       =   leafbio.(varname)*1.01;
            canopy.LAI              =   leafbio.LAI;
            SCOPE_run


%             Ts_ref = 0;
%             Tcu_ref = 0;
%             Tch_ref = 0;
            S_Lot_(:,j,ilai,iRin)   =   abs(Lot_ref_ - rad.Lot_);
            S_Ts(:,j,ilai,iRin)     =   abs(Ts_ref   - thermal.Ts);
            S_Tch(:,j,ilai,iRin)    =   abs(Tch_ref  - thermal.Tch);
            S_Tcu(:,j,ilai,iRin)    =   abs(Tcu_ref  - permute(mean(mean(thermal.Tcu,1),2),[3 1 2]));

        end
    end
end


%% Post Processing
% MODIS bands
[~,iband_1]                         =   min((spectral.wlS - (10.780 + 11.280)/2*1e3).^2);
[~,iband_2]                         =   min((spectral.wlS - (11.770 + 12.270)/2*1e3).^2);

S_Lot_1                             =   permute(S_Lot_(iband_1,:,:,:),[3 4, 2 1]);
S_Lot_2                             =   permute(S_Lot_(iband_2,:,:,:),[3 4, 2 1]);     %sunlit

S_Tsh                               =   permute(S_Ts(1,:,:,:),[3 4, 2 1]);
S_Tsu                               =   permute(S_Ts(2,:,:,:),[3 4, 2 1]);     %sunlit


S_Tch_t                             =   permute(S_Tch( 1,:,:,:),[3 4, 2 1]);
S_Tcu_t                             =   permute(S_Tcu( 1,:,:,:),[3 4, 2 1]);   %sunlit


S_Tch_m                             =   permute(S_Tch(30,:,:,:),[3 4, 2 1]);
S_Tcu_m                             =   permute(S_Tcu(30,:,:,:),[3 4, 2 1]);   %sunlit


S_Tch_b                             =   permute(S_Tch(60,:,:,:),[3 4, 2 1]);
S_Tcu_b                             =   permute(S_Tcu(60,:,:,:),[3 4, 2 1]);   %sunlit

%% Quantiles
q                                   =   [0.05, 0.5, 0.95];
for iq=1:length(q)
    S_Lot_1b(:,iq,:)                 =   quantile(S_Lot_1,q(iq),2);
    S_Lot_2b(:,iq,:)                 =   quantile(S_Lot_2,q(iq),2);

    S_Tshb(:,iq,:)                   =   quantile(S_Tsh,q(iq),2);
    S_Tsub(:,iq,:)                   =   quantile(S_Tsu,q(iq),2);


    S_Tch_tb(:,iq,:)                 =   quantile(S_Tch_t,q(iq),2);
    S_Tcu_tb(:,iq,:)                 =   quantile(S_Tcu_t,q(iq),2);


    S_Tch_mb(:,iq,:)                 =   quantile(S_Tch_m,q(iq),2);
    S_Tcu_mb(:,iq,:)                 =   quantile(S_Tcu_m,q(iq),2);


    S_Tch_bb(:,iq,:)                 =   quantile(S_Tch_b,q(iq),2);
    S_Tcu_bb(:,iq,:)                 =   quantile(S_Tcu_b,q(iq),2);
end
legendstr = {' 5%%','50%%','95%%'};


S_Lot_1                 =   S_Lot_1b;
S_Lot_2                 =   S_Lot_2b;

S_Tsh                   =   S_Tshb;
S_Tsu                   =   S_Tsub;


S_Tch_t                 =   S_Tch_tb;
S_Tcu_t                 =   S_Tcu_tb;


S_Tch_m                 =   S_Tch_mb;
S_Tcu_m                 =   S_Tcu_mb;


S_Tch_b                 =   S_Tch_bb;
S_Tcu_b                 =   S_Tcu_bb;

%%
Nparam = length(varnames);
Nc = 3;
Nr = ceil(Nparam/Nc);

% max(S_Tch_b,[],3)
%% Soil
figure('Position',[20 20 1024 800])
for j=1:Nparam
    h(j) = subplot(Nr,Nc,j);
%     semilogy(LAI,max(S_Tsu,[],3),'color',[0.8 0.8 0.8]); hold on
    semilogy(LAI,S_Tsu(:,:,j)+1e-12);
    ylabel(varnames{j})
    
    ylim([1e-6 1e0])
    set(gca,'ytick',[logspace(-6,1,6)])
    grid on    
    
    if j==2
        title('Prospect sensitivity of Sunlit Soil Temperature (for different LAI values)')
    end
    if j==5
        legend(legendstr)
    end
    if j>6
        xlabel('LAI [m2/m2]')
    end
end



figure('Position',[20 20 1024 800])
for j=1:Nparam
    h(j) = subplot(Nr,Nc,j);
    semilogy(LAI,S_Tsh(:,:,j)+1e-12); hold on
    ylabel(varnames{j})
    
    
    ylim([1e-5 1e0])
    set(gca,'ytick',[logspace(-5,1,6)])
    grid on    
    
    if j==2
        title('Prospect sensitivity of Shaded Soil Temperature (for different LAI values)')
    end
    
    if j==5
        legend(legendstr)
    end
    if j>6
        xlabel('LAI [m2/m2]')
    end
end


%% Vegetation
figure('Position',[20 20 1024 800])
for j=1:Nparam
    h(j) = subplot(Nr,Nc,j);
    semilogy(LAI,S_Tcu_b(:,:,j));
    ylabel(varnames{j})
    
    ylim([1e-5 1e0])
    set(gca,'ytick',[logspace(-5,1,6)])
    grid on    
    
    if j==2
        title('Prospect sensitivity of Sunlit Bottom Canopy Temperature (for different LAI values)')
    end
    if j==5
        legend(legendstr)
    end
    if j>6
        xlabel('LAI [m2/m2]')
    end
end


figure('Position',[20 20 1024 800])
for j=1:Nparam
    h(j) = subplot(Nr,Nc,j);
    semilogy(LAI,S_Tch_b(:,:,j));
    ylabel(varnames{j})
    
    ylim([1e-5 1e0])
    set(gca,'ytick',[logspace(-5,1,6)])
    grid on    
    
    if j==2
        title('Prospect sensitivity of Shaded Bottom Canopy Temperature (for different LAI values)')
    end
    if j==5
        legend(legendstr)
    end
    if j>6
        xlabel('LAI [m2/m2]')
    end
end


figure('Position',[20 20 1024 800])
for j=1:Nparam
    h(j) = subplot(Nr,Nc,j);
    semilogy(LAI,S_Tcu_t(:,:,j));
    ylabel(varnames{j})
    
    ylim([1e-5 1e0])
    set(gca,'ytick',[logspace(-5,1,6)])
    grid on    
    
    if j==2
        title('Prospect sensitivity of Sunlit Top Canopy Temperature (for different LAI values)')
    end
    if j==5
        legend(legendstr)
    end
    if j>6
        xlabel('LAI [m2/m2]')
    end
end



figure('Position',[20 20 1024 800])
for j=1:Nparam
    h(j) = subplot(Nr,Nc,j);
    semilogy(LAI,S_Tch_t(:,:,j));
    ylabel(varnames{j})
    
    ylim([1e-5 1e0])
    set(gca,'ytick',[logspace(-5,1,6)])
    grid on    
    
    if j==2
        title('Prospect sensitivity of Shaded Top Canopy Temperature (for different LAI values)')
    end
    if j==5
        legend(legendstr)
    end
    if j>6
        xlabel('LAI [m2/m2]')
    end
end


%% Radiation
figure('Position',[20 20 1024 800])
for j=1:Nparam
    h(j) = subplot(Nr,Nc,j);
    semilogy(LAI,S_Lot_1(:,:,j));
    ylabel(varnames{j})
    
    ylim([1e-6 1e0])
    set(gca,'ytick',[logspace(-6,1,6)])
    grid on    
    
    if j==2
        title('Prospect sensitivity of Outgoing Radiation @ MODIS Band31 (for different LAI values)')
    end
    if j==5
        legend(legendstr)
    end
    if j>6
        xlabel('LAI [m2/m2]')
    end
end


figure('Position',[20 20 1024 800])
for j=1:Nparam
    h(j) = subplot(Nr,Nc,j);
    semilogy(LAI,S_Lot_2(:,:,j));
    ylabel(varnames{j})
    
    ylim([1e-6 1e0])
    set(gca,'ytick',[logspace(-6,1,6)])
    grid on    
    
    if j==2
        title('Prospect sensitivity of Outgoing Radiation @ MODIS Band32 (for different LAI values)')
    end
    if j==5
        legend(legendstr)
    end
    if j>6
        xlabel('LAI [m2/m2]')
    end
end


