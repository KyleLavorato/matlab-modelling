%% P1 Project - Urban Agriculture Design
% This script computes the finincial feasibility of an urban farm
% through the use of many basic MATLAB(R) functions.
% Results of relevant data are displayed graphically through the use of
% figures in relevant data intervals.

%% Coder Information
%
% * Kyle Lavorato


%% Prep

clc;
close all;
clear all;

%% Net Present Value - Urban Farm

fprintf('\n')
fprintf(2,'Urban Farm NPV \n')
fprintf('\n')

% Cost of 9 gardening containers
ContainerCost=-2109.73;

% Cost of materials to build farm
StructureCost=-17222;

% Cost of first year seeds and soils
% (Seed + soil)
SeedSoilCost=270+3400.67;

% Total cost of farm materials
PurchaseFarm=-ContainerCost+StructureCost+SeedSoilCost;

% Cost to build farm
ConstructFarm=-37673.30;

% Annual utilities cost
% (Water + Hydro)
UtilitiesFarm=-2040.60-1119.19;

% Annual rent
RentCost=-22010.88;

% Annual worker wages
WorkerWages=-23387;

% Total annual costs
TotalAnnual=UtilitiesFarm+RentCost+WorkerWages

% Annual crop profits
% (Tomato + Basil + Cabbage (*6) + Kale + mushrooms + Garlic)
CropProfits=400*5.30+400*11.78+400*4.52*6+200*4.42+260*175+60*3.40;

% Annual extra pofits
% (Intern savings + tour/workshop profits)
ExtraProfits=1349.25+2500;

% Total annual profits
TotalProfits=CropProfits+ExtraProfits

% Initial net present value
NPV=PurchaseFarm+ConstructFarm+RentCost

% NPV array for graph
NPVD(1)=NPV;

% Maximum payback period
FarmLife=0:4;

for i=1:4
    % Increase of profit in year 3 by 25%
    if i==3
        CropProfits=CropProfits*1.25;
        TotalProfits=CropProfits+ExtraProfits
    end
    
    % Calculate NPV
    NPV=NPV+(TotalProfits+TotalAnnual)/(1.12)^i;
    NPVD(i+1)=NPV;
    fprintf('At year %d the Urban Farm will have a NPV of $%.2f \n',i,NPV)
end

%% Plot Net Present Value

figure(1)
plot([0,4],[ 0 0], 'k-')
hold on
plot(FarmLife,NPVD,'r')
hold on

% Graph Formatting
title('Net Present Value of the Urban Farm')
xlabel('Years After Purchase')
ylabel('Net Present Value [$$$]')
legend('Break Even','Urban Farm','Location','NorthWest')
%axis([0 1 -250000 50000])
axis 'auto x'
set(gca,'YTickLabel',strcat('$',num2str(get(gca,'YTick').')))

