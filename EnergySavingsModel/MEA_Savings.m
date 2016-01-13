%% P2 Project - Modelling the NPV and Effieiency of Energy Saving Heating
% This script analyzes and computes the modeled/projected savings and 
% net present value from various energy saving ideas using of many 
% basic MATLAB® functions. Results of the model data is displayed 
% graphically through the use of figures in relevant data intervals. 
% Text based output is used to display the relevant data where exact 
% numbers are required for data analysis.

%% Coder Information
%
% * Kyle Lavorato

%% Prep

clc;
close all;
clear all;

%% Declare starting values

FILENAME='EnthalpySupplyEnteringTemp.txt';
[SupplyEnteringTemp,SupplyEnteringTempDate] = GetBuildingData(FILENAME);

FILENAME='EnthalpySupplyEnteringHumidity.txt';
[SupplyEnteringHumidity,SupplyEnteringHumidityDate] = GetBuildingData(FILENAME);

ExhaustEnteringTemp=25; % °C

ExhaustEnteringHumidity=30; % Percent

Pressure=1000; % Millibars

%% Other Air-to-Air Section
%% Calculate Enthalpies

% Supply Entering Enthalpy
SEE=1.005.*(SupplyEnteringTemp+273);
% Exhaust Entering Enthalpy
EEE=1.005*(25+273);

% Efficiencies
ATAEff=[45 55 65]/100;

for i=1:3
    for j=1:numel(SEE)
        % Erase summer data points
        if j>=1081 && j<=3649
            SLE(j,i)=NaN;
            SLT(j,i)=NaN;
        else
            % Calculate enthalpy
            g=@(SLE) (SEE(j)-SLE)./(SEE(j)-EEE)-ATAEff(i);
            SLE(j,i)=fzero(g,0);
            % Calculate temperature
            u=@(T) (SEE(j)-1.005.*(T+273))./(SEE(j)-EEE)-ATAEff(i);
            SLT(j,i)=fzero(u,0);
        end
    end
end

%% Graphical Output for Air-to-Air

% Figure number
figure(1)

% Plot data
plot(SupplyEnteringTempDate,SupplyEnteringTemp,'.b');
hold on
plot(SupplyEnteringTempDate(500),0,'w')
hold on
plot(SupplyEnteringTempDate,SLT(:,1),'.c');
hold on
plot(SupplyEnteringTempDate,SLT(:,2),'.m');
hold on
plot(SupplyEnteringTempDate,SLT(:,3),'.r');

% Graph formatting
datetick('x','dd-mmm','keepticks')
title('Temperatures From The Air-to-Air System')
legend('Supply Entering Temp','Supply Leaving Temp','45% Efficiency','55% Efficiency','65% Efficiency','Location','SouthEast')
xlabel('Date')
ylabel('Temperature [°C]')
axis([SupplyEnteringTempDate(1) SupplyEnteringTempDate(end) 0 1]);
axis 'auto y'

%% Enthapy Hwheel Section
%% Calculate Enthalpy of Supply Entering

% Saturated vapour pressure
ps=610.78.*exp(17.27.*SupplyEnteringTemp./(SupplyEnteringTemp+238.3));

% Partial vapour pressure of water
p=(SupplyEnteringHumidity/100).*ps;

x=0.62.*p./((Pressure*1000)-p);

% Relative enthalpy
SupplyEnteringEnthalpy=1.005.*(SupplyEnteringTemp+273)+x.*(2501+1.84.*(SupplyEnteringTemp+273));

%% Calculate Enthalpy of Exhaust Entering

% Saturated vapour pressure
ps=610.78.*exp(17.27.*ExhaustEnteringTemp./(ExhaustEnteringTemp+238.3));

% Partial vapour pressure of water
p=(ExhaustEnteringHumidity/100).*ps;

x=0.62.*p./((Pressure*1000)-p);

% Relative enthalpy
ExhaustEnteringEnthalpy=1.005.*(ExhaustEnteringTemp+273)+x.*(2501+1.84.*(ExhaustEnteringTemp+273));

%% Efficiency Calculations

% Given efficiency values
Efficiency=[50 67.5 85]/100;

for i=1:3
    for j=1:numel(SupplyEnteringEnthalpy)
        % Zero summer months
        if j>=1081 && j<=3649
            SupplyLeavingEnthalpy(j,i)=NaN;
        else
            f=@(SLE) (SupplyEnteringEnthalpy(j)-SLE)./(SupplyEnteringEnthalpy(j)-ExhaustEnteringEnthalpy)-Efficiency(i);
            SupplyLeavingEnthalpy(j,i)=fzero(f,0);
        end
    end
end

%% Calculate Enthalpy of Supply Leaving

% Relative Humidity
for i=1:3
    RH(i)=ExhaustEnteringHumidity/Efficiency(i);
end

% Super Equation to calculate temperature

for i=1:3
    for j=1:numel(SupplyEnteringEnthalpy)
        % Zero summer months
        if j>=1081 && j<=3649
            Temp(j,i)=NaN;
        else
            h=@(T) 1.005.*(T+273)+(0.62.*((RH(i)/100).*(610.78.*exp(17.27.*T./(T+238.3))))./((Pressure*1000)-((RH(i)/100).*(610.78.*exp(17.27.*T./(T+238.3)))))).*(2501+1.84.*(T+273))-SupplyLeavingEnthalpy(j,i);
            Temp(j,i)=fzero(h,0);
        end
    end
end

%% Graphical Output for Enthalpy Hwheel

% Figure number
figure(2)

% Plot data
plot(SupplyEnteringTempDate,SupplyEnteringTemp,'.b');
hold on
plot(SupplyEnteringTempDate(500),0,'w')
hold on
plot(SupplyEnteringTempDate,Temp(:,1),'.c');
hold on
plot(SupplyEnteringTempDate,Temp(:,2),'.m');
hold on
plot(SupplyEnteringTempDate,Temp(:,3),'.r');

% Graph formatting
datetick('x','dd-mmm','keepticks')
legend('Supply Entering Temp','Supply Leaving Temp','50% Efficiency','67.5% Efficiency','85% Efficiency','Location','SouthEast')
xlabel('Date')
ylabel('Temperature [°C]')
title('Temperatures From The Enthalpy Wheel System')
axis([SupplyEnteringTempDate(1) SupplyEnteringTempDate(end) 0 1]);
axis 'auto y'

%% Enthalpy Hwheel Real Data Model
%% Import Real Data

FILENAME='EnthalpySupplyLeavingTemp.txt';
[RealSupplyLeavingTemp,RealSupplyLeavingTempDate] = GetBuildingData(FILENAME);

FILENAME='EnthalpySupplyLeavingHumidity.txt';
[RealSupplyLeavingHumidity,RealSupplyLeavingHumidityDate] = GetBuildingData(FILENAME);

FILENAME='Pressure.txt';
[RealPressure,RealPressureDate] = GetBuildingData(FILENAME);

%% Calculate Enthalpy of Supply Leaving

% Saturated vapour pressure
ps=610.78.*exp(17.27.*RealSupplyLeavingTemp./(RealSupplyLeavingTemp+238.3));

% Partial vapour pressure of water
p=(RealSupplyLeavingHumidity/100).*ps;

x=0.62.*p./((RealPressure*1000)-p);

% Relative enthalpy
RealSupplyLeavingEnthalpy=1.005.*(RealSupplyLeavingTemp+273)+x.*(2501+1.84.*(RealSupplyLeavingTemp+273));

RealSupplyLeavingEnthalpyNaN=RealSupplyLeavingEnthalpy;

% Zero sumer months
RealSupplyLeavingEnthalpyNaN(1081:3649)=NaN;

%% Compare Model to Real Data

% Figure number
figure(3)

plot(RealSupplyLeavingTempDate,RealSupplyLeavingEnthalpyNaN,'.b')
hold on
plot(SupplyEnteringTempDate(500),0,'w')
hold on
plot(RealSupplyLeavingTempDate,SupplyLeavingEnthalpy(:,1),'.c')
hold on
plot(RealSupplyLeavingTempDate,SupplyLeavingEnthalpy(:,2),'.m')
hold on
plot(RealSupplyLeavingTempDate,SupplyLeavingEnthalpy(:,3),'.r')

% Graph formatting
datetick('x','dd-mmm','keepticks')
legend('Real Supply Leaving Enthalpy','Model Supply Leaving Enthalpy','50% Efficiency','67.5% Efficiency','85% Efficiency','Location','SouthEast')
xlabel('Date')
ylabel('Joules [J]')
title('Comparision of Real Supply Leaving Enthalpy Data With Model')
axis([SupplyEnteringTempDate(1) SupplyEnteringTempDate(end) 0 1]);
axis 'auto y'

%% Estimate Average Airflow in ILC

FILENAME='SupplyFanVolume.txt';
[SupplyFanVolume,SupplyFanVolumeDate] = GetBuildingData(FILENAME);

FanVolume=sum(SupplyFanVolume)/length(SupplyFanVolume); % L/s taken from above plot

%% Enthalpy Hwheel Effectiveness Period
%% Import More Real Data

RealSupplyEnteringTemp=SupplyEnteringTemp;

RealSupplyEnteringHumidity=SupplyEnteringHumidity;

FILENAME='EnthalpyExhaustEnteringTemp.txt';
[RealExhaustEnteringTemp,RealExhaustEnteringTempDate] = GetBuildingData(FILENAME);

FILENAME='EnthalpyExhaustEnteringHumidity.txt';
[RealExhaustEnteringHumidity,RealExhaustEnteringHumidityDate] = GetBuildingData(FILENAME);

%% Calculate Real Enthalpies
%% Supply Entering Enthalpy 

% Saturated vapour pressure
ps=610.78.*exp(17.27.*RealSupplyEnteringTemp./(RealSupplyEnteringTemp+238.3));

% Partial vapour pressure of water
p=(RealSupplyEnteringHumidity/100).*ps;

x=0.62.*p./((RealPressure*1000)-p);

% Relative enthalpy
RealSupplyEnteringEnthalpy=1.005.*(RealSupplyEnteringTemp+273)+x.*(2501+1.84.*(RealSupplyEnteringTemp+273));

%% Exhaust Entering Enthalpy

% Saturated vapour pressure
ps=610.78.*exp(17.27.*RealExhaustEnteringTemp./(RealExhaustEnteringTemp+238.3));

% Partial vapour pressure of water
p=(RealExhaustEnteringHumidity/100).*ps;

x=0.62.*p./((RealPressure*1000)-p);

% Relative enthalpy
RealExhaustEnteringEnthalpy=1.005.*(RealExhaustEnteringTemp+273)+x.*(2501+1.84.*(RealExhaustEnteringTemp+273));

%% Calculate Efficiency
obsEnth=RealSupplyEnteringEnthalpy-RealSupplyLeavingEnthalpy;
possEnth=RealSupplyEnteringEnthalpy-RealExhaustEnteringEnthalpy;

efficiency=obsEnth./possEnth;

%% Set Data Flags

% Array to hold boolean flags for volume
VolumeFlag=zeros(1,numel(SupplyFanVolume));

% Set flag based on trigger of volume reaching 1000 L/s
for i=1:numel(SupplyFanVolume)
    if SupplyFanVolume(i)>1000
        VolumeFlag(i)=1;
    else
        VolumeFlag(i)=0;
    end
end

% Array to hold boolean flags for temperature
EnteringFlag=zeros(1,numel(ExhaustEnteringTemp));

% Set flag based on trigger of temperature difference being less than 5°C
for i=1:numel(RealSupplyLeavingTemp)
    if abs(RealSupplyEnteringTemp(i)-RealExhaustEnteringTemp(i))<5
        EnteringFlag(i)=0;
    else
        EnteringFlag(i)=1;
    end
end
%% Apply Data Flags

% Zero efficiency when the flags state false to prevent 'garbage data'
for i=1:numel(efficiency)
    if EnteringFlag(i)==0
        efficiency(i)=0;
    end
    if VolumeFlag(i)==0
        efficiency(i)=0;
    end
end

%% Plot Real Efficiency

% Graph formatting
figure(4)
plot(RealSupplyLeavingTempDate,efficiency*100,'.');
xlabel('Date')
ylabel('Efficiency [%]')
title('Efficiency of the Enthalpy Wheel Over Time')
datetick('x','dd-mmm','keepticks')
axis([SupplyEnteringTempDate(1) SupplyEnteringTempDate(end) 0 1]);
axis 'auto y'

%% Calculate Total Energy Saved

% Density of Air
Density=0.001204; % kg/L

EnthalpyDifference=abs(EEE-SEE); % kJ/kg
EnthalpyDifference(1081:3649)=0;
EnergySaved=(EnthalpyDifference*FanVolume*Density)*2;
TotalEnergySaved=sum(EnergySaved); % kWh

%{
% Integral Function
q=EnthalpyDifference(:,1).*Density.*FanVolume;

EnergyList=cumtrapz(q)
EnergySaved(:,1)=sum(EnergyList)*2
%}

%% Calculate Emissions and Cost Saved

EnergyContent=12; % kWh/kgfuel
CO2Emission=2.8; % kgCO2/kgfuel
GasCost=0.271931; % $/kgfuel

kgGas=TotalEnergySaved/EnergyContent;
CO2Emitted=kgGas*CO2Emission;

MoneySaved=kgGas*GasCost;
MoneySaved=sum(MoneySaved);

%% Standard Ellis Hall Power Consumption
% This data is from the 2013 year period for the ILC as the Data was
% unavailable for Ellis. Additionally the previous year's data for Ellis
% is very unreliable and has huge holes.

FILENAME='EllisPower.txt';
[EllisPower,EllisPowerDate] = GetBuildingData(FILENAME);

% Convert Ellis power to kWh
EllisPower=EllisPower/1000*2;

EllisCost=EllisPower/EnergyContent*GasCost;
EllisCost=sum(EllisCost);

fprintf(2,'Energy Information \n')
fprintf('\n')
fprintf('The total amount of energy saved by the system is %.2f kWh \n',TotalEnergySaved)
fprintf('The total amount of energy currently used by Ellis %.2f kWh \n',sum(EllisPower))
fprintf('\n')

% Create a Figure
figure(5);

% Prepare to plot Ellis 
EnergyPlot=EnergySaved;
EnergyPlot(1081:3649)=NaN;
plot(EllisPowerDate,EllisPower,'.')
hold on
plot(EllisPowerDate,EnergyPlot,'.r')

% Graph Formatting
datetick('x','dd-mmm','keepticks')
title('Power Consumption and Recovery of Ellis Hall')
xlabel('Date')
ylabel('Power Consumption [kWh]')
legend('Ellis Consumed Energy','Recovered Energy','Location','NorthWest')
axis([SupplyEnteringTempDate(1) SupplyEnteringTempDate(end) 0 1]);
axis 'auto y'

fprintf(2,'Money and CO2 Savings \n')
fprintf('\n')
fprintf('The money saved by the system is $%.2f \n',MoneySaved)
fprintf('The total cost to run Ellis normally is $%.2f \n',EllisCost)
fprintf('The system saves %.2f kg of CO2 \n',CO2Emitted)


%% Net Present Value - Runaround Coil Loop

fprintf('\n')
fprintf(2,'Runaround Coil Loop NPV \n')
fprintf('\n')

PurchaseCoil=-63538.94;
InstallCoil=-30256.30;
MaintainCoil=-348.27;

NPVc=PurchaseCoil+InstallCoil;
NPVDc(1)=NPVc;
CoilLife=0:15;

for i=1:15
    NPVc=NPVc+(MoneySaved+MaintainCoil)/(1.12)^i;
    NPVDc(i+1)=NPVc;
    if i==4
        fprintf('At year 4 the Coil Loop will have a NPV of $%.2f \n',NPVc)
    end
end

fprintf('By the minimum end of life of the Coil Loop, the NPV will be $%.2f \n',NPVc)

%% Net Present Value - Heat Pipe

fprintf('\n')
fprintf(2,'Heat Pipe NPV')
fprintf('\n')

PurchaseHeat=-47187.84;
InstallHeat=-30000;
MaintainHeat=-112.35;

NPVh=PurchaseHeat+InstallHeat;
NPVDh(1)=NPVh;
HeatLife=0:15;

for i=1:15
    NPVh=NPVh+(MoneySaved+MaintainHeat)/(1.12)^i;
    NPVDh(i+1)=NPVh;
    if i==4
        fprintf('At year 4 the Heat Pipe will have a NPV of $%.2f \n',NPVh)
    end
end

fprintf('By the minimum end of life of the Heat Pipe, the NPV will be $%.2f \n',NPVh)

%% LED Lights
%% Energy and CO2 Savings

AnnualF=102277;
AnnualLED=72012.43;

LightEnergySaved=AnnualF-AnnualLED;

kgGasLights=LightEnergySaved/EnergyContent;
CO2EmittedLights=kgGasLights*CO2Emission;

MoneySavedLights=kgGasLights*GasCost;

fprintf('\n')
fprintf(2,'LED Lights Savings')
fprintf('\n')
fprintf('The money saved by the LED lights is $%.2f \n',MoneySavedLights)
fprintf('The system saves %.2f kg of CO2 \n',CO2EmittedLights)

%% Net Present Value - Lights

fprintf('\n')
fprintf(2,'LED Lights NPV')
fprintf('\n')

PurchaseLED=-90128;

NPVl=PurchaseLED;
NPVDl(1)=NPVl;
LightLife=0:15;

for i=1:15
    NPVl=NPVl+(MoneySavedLights)/(1.12)^i;
    NPVDl(i+1)=NPVl;
    if i==4
        fprintf('At year 4 the LED lights will have a NPV of $%.2f \n',NPVl)
    end
    if i==8
        fprintf('At worst worst case life span, the LED lights will have a NPV of $%.2f in year 8 \n',NPVl)
    end
end

fprintf('By the best case end of life span, the LED lights will have a NPV of $%.2f in year 15 \n',NPVl)

%% Solar Array
%% Energy and CO2 Savings

A=1358; % m^2
r=0.157; % Percent
H=3.53; % kWh/m^2/day
PR=0.75; % Percent

SolarEnergyProduced=A*r*H*PR; % kWh/day
SolarEnergyProduced=SolarEnergyProduced*365; % kWh/Year

kgGasSolar=SolarEnergyProduced/EnergyContent;
CO2EmittedSolar=kgGasSolar*CO2Emission;

MoneySavedSolar=kgGasSolar*GasCost;

fprintf('\n')
fprintf(2,'Solar Array Savings')
fprintf('\n')
fprintf('The money saved by the solar array is $%.2f \n',MoneySavedSolar)
fprintf('The system saves %.2f kg of CO2 \n',CO2EmittedSolar)

%% Net Present Value - Solar Array

fprintf('\n')
fprintf(2,'Solar Array NPV')
fprintf('\n')

% Average of the cost of 3 different systems
PurchaseSolar=-199500;

NPVs=PurchaseSolar;
NPVDs(1)=NPVs;
SolarLife=0:40;

for i=1:40
    NPVs=NPVs+(MoneySavedSolar)/(1.12)^i;
    NPVDs(i+1)=NPVs;
    if i==4
        fprintf('At year 4 the solar array will have a NPV of $%.2f \n',NPVs)
    end
    if i==30
        fprintf('At worst worst case life span, the solar array will have a NPV of $%.2f in year 30 \n',NPVs)
    end
end

fprintf('By the best case end of life span, the solar array will have a NPV of $%.2f in year 40 \n',NPVs)

%% Plot Net Present Value

figure(6)
% Horizontal line function
plot([0,40],[ 0 0], 'k-')
hold on

hold on
plot(CoilLife,NPVDc,'g')
hold on
plot(HeatLife,NPVDh,'r')
hold on
plot(LightLife,NPVDl,'m')
hold on
plot(SolarLife,NPVDs,'c')


% Graph Formatting
title('Net Present Value of Energy Saving Options')
xlabel('Years After Purchase')
ylabel('Net Present Value [$$$]')
legend('Break Even','Coil Loop','Heat Pipe','LED Lights','Solar Array','Location','NorthEast')
axis([0 1 -250000 50000])
axis 'auto x'
%yt = get(gca,'YTick'); Does not work in current matlab version
%set(gca,'YTickLabel', sprintf('$%.2f|',yt))
set(gca,'YTickLabel',strcat('$',num2str(get(gca,'YTick').')))


%% THE PROGRAM IS DONE
%load handel
%sound(y,Fs)
