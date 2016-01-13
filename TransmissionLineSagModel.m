%% MEA 1 - Modelling the Sag in High Voltage Transmission Lines
% This script analyzes and computes the maximum sag in high voltage
% transmission lines through the use of many basic MATLAB(R) functions.
% Results of relevant data are displayed graphically through the use of
% figures in relevant data intervals.

%% Coder Information
%
% * Kyle Lavorato

%% Prep

% Kill all open figures (This line was taken from a MATLAB help forum)
delete(findall(0,'Type','figure'));

% Clear the command window
clc;

%% Declare variables

% Current in the line
I=[356,556,756]; % A

% Linear coefficient of thermal expansion
TE=[19.3e-6 17.8e-6]; % m/K

% Initial length of the conductor
Li=[270.2 270.4]; % m

% Initial temperature
Ti=293.15; % K

% Horizontal span between towers
S=270; % m

% Resistivity of the conductor per unit length
R=[0.0000516 0.0000516]; %Ohms/m

% The diameter of the conductor
D=[0.03180 0.03270]; %m

% The absorptivity coefficient of the conductor
alpha=0.5; % Percentage

% The emissivity coefficient of the conductor
epsilon=0.2; % Percentage

% The solar irradiance
Gs=708.75; %W/m^2

% The coefficient of convective heat transfer
h=10; %W/m^2K

% The Stefan-Boltzmann constant
sigma=5.67*10^-8; %W/m^2K^4

% The ambient temperature
Ta=linspace(298.05,303.05, 56); %K

% Colours for the lines of graph set 1
colours=['m' 'k' 'c'];

% Colours for the lines of graph set 2
colour=['r' 'b' 'g'];

% The year x values for the plot
x=[2015:2070];

%% Calculations

% Calculate each different type of wire
for m=1:2
    
    %{
    % Data Output for Table DO NOT DISPLAY IN FINAL
    fprintf(2,'Wire Type %d \n',m)
    fprintf('\n')
    %}
    
    % An empty 3D array to hold the calculated y values
    Tf=zeros(1,56,3);

    %%%  Temperature Calculations

    % For all yearly ambient tempatures
    for i=1:56

        % For each current value
        for j=1:3

            % Solar irradiation into the conductor
            Qs=alpha*D(m)*Gs;
            % Coulombic losses generated internally
            Qgen=I(j)^2*R(m);

            % Total internal energy
            Q=Qs+Qgen;

            % Formula for fzero()
            f=@(T) h*pi()*D(m)*(T-Ta(i))+sigma*epsilon*pi()*D(m)*(T^4-Ta(i)^4)-Q;

            % The answer added to the matrix
            Tf(1,i,j)=fzero(f,0);
            %fprintf('%.2f \n',Tf(i))

        end

    end

    %%% Temperature Plot

    % Create the first figure
    figure;

    % Plot the 3 lines of the first figure
    for i=1:3

        plot(x,Tf(:,:,i),colours(i));
        hold on

    end

    % Graph Formatting
    ylabel('Temperature in Line [K]');
    xlabel('Time [Years]');
    legend('356 A','556 A','756 A','Location','NorthWest');

    % Axis range
    xAxisMin=x(1);
    xAxisMax=x(end);
    yAxisMin=Tf(:,1,1)-1;
    yAxisMax=Tf(:,end,end)+1;
    axis([xAxisMin,xAxisMax,yAxisMin,yAxisMax]);

    %%% Maximum Sag Calculations

    % Declare an empty 3D list for the sag values
    sag=zeros(1,56,3);

    % For 3 Li values
    for k=1:2

        % For 56 temperature values
        for i=1:56

            % For 3 current values
            for j=1:3

                % Length of the conductor
                L=Li(k)*(1+TE(m)*(Tf(1,i,j)-Ti));
                %fprintf('%.2f %.2f \n',Tf(i),Ti)

                % Calculate the maximum sag
                sag(1,i,j)=sqrt((3*S*(L-S))/8);
                %fprintf('%.2f \n',sag)

            end

        end

        %%% Graphical Output

        % Create a new figure
        figure;

        % Plot the 3 different current lines
        for i=1:3

            plot(x,sag(:,:,i),colour(i))
            hold on

        end

        %{
        % Data Output for Table DO NOT DISPLAY IN FINAL
        fprintf(2,'Wire Length %.1f m \n',Li(k))
        
        % Data Output for Table DO NOT DISPLAY IN FINAL
        for i=1:3
    
            fprintf(2,'Current %d A \n',I(i))
            data=sag(:,:,i)
    
        end
        %}
        
        %Graph formatting
        xlabel('Time [Years]')
        ylabel('Line Sag [m]')

        legend('356 A','556 A','756 A');
        legend('Location','NorthWest');

        % Axis range
        xAxisMin=x(1);
        xAxisMax=x(end);
        yAxisMin=sag(:,1,1)-.2;
        yAxisMax=sag(:,end,end)+.2;
        axis([xAxisMin,xAxisMax,yAxisMin,yAxisMax]);

    end

end

% Add titles to graphs based on figure number
figure(1)
title('Temperature in Line Over Time for ACSR 560 7 Steel wires');
figure(2)
title('Maximum Transmission Line Sag Over Time For 270.2 m Line for ACSR 560 7 Steel wires')
figure(3)
title('Maximum Transmission Line Sag Over Time For 270.4 m Line for ACSR 560 7 Steel wires')
figure(4)
title('Temperature in Line Over Time ACSR 560 19 Steel wires');
figure(5)
title('Maximum Transmission Line Sag Over Time For 270.2 m Line ACSR 560 19 Steel wires')
figure(6)
title('Maximum Transmission Line Sag Over Time For 270.4 m Line ACSR 560 19 Steel wires')