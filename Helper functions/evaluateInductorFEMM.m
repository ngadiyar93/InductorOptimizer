function [losses, force, volume, mass, Ind, Res] = evaluateInductorFEMM(dimensions, winding, settings)

% EVALUATEINDUCTOR builds and evaluates the inductor design using FEMM
% 
% REQUIRED ARGUMENTS
% dimensions: Inductor dimensions.
% settings: structure containing the FEA settings
%
% OUTPUT VARIABLES (For structures: "+" = added, "~" = modified)
% loss: structure with core losses at the operating point
% force: force between the two cores
% volume: Inductor volume
% mass: Mass of the inductor
% Ind: Inductance in [H]
% Res: Resistance in [ohms]

t_T=dimensions.t_T;
t_Cu=dimensions.t_Cu;
t_C = dimensions.t_C;
g=dimensions.g;
w_E=dimensions.w_E;
w_C=dimensions.w_C;
w_I=w_E-w_C;
depth=dimensions.d;

turns=winding.N_t;
gauge = winding.gauge;

I_pk = settings.I_pk;
meshSize = settings.meshSize;
steps = settings.steps;
f = settings.frequency;
lowestHarmonic = 1;
%% FEMM 
openfemm(1);
newdocument(0);
mi_probdef(0,'meters','planar',1e-8,depth,-30,0);

%% Materials
coilMaterial = sprintf('%i AWG',gauge);
coreMaterial = 'coreMat';
import_corematerial(coreMaterial);
mi_getmaterial('Air');
mi_getmaterial(coilMaterial);
rho_core = 5.5*1000; % Mass density in units of kg/m^3
rho_Cu = 8954;

%% Groups
EcoreGroup = 1;
IcoreGroup = 2;
coilGroup = 3;
airGroup = 4;

%% add circuits: mi_addcircprop(circuitname, i, circuittype)
mi_addcircprop('A', 0, 1)
%% Boundary Conditions: mi_addboundprop(propname, A0, A1, A2, Phi, Mu, Sig, c0, c1, BdryFormat,ia, oa)
mi_addboundprop('neumann', 0, 0, 0, 0, 0, 0, 0, 0, 0,0, 0);
mi_setgrid(1,'cart'); 

threadID = get(getCurrentTask(),'ID');

if(isempty(threadID))
    filename = 'testDesign.fem';
    ansfile = 'testDesign.ans';
else
    filename = [num2str(threadID),'.fem'];
    ansfile = [num2str(threadID),'.ans'];
end

mi_saveas(filename);

%% Make I core
% Draw_rectangle(x,y,dim_w,dim_h,name,group,varargin)
width = 2*(t_T + t_Cu)+t_C;
height = w_I;
Draw_rectangle(0,0,width,height,coreMaterial,IcoreGroup,'automesh',0,'meshsize',meshSize);

%% Make E core
% Teeth 
width = t_T;
height = w_C;
% Tooth 1
x_coord = 0;
y_coord = w_I+g;
Draw_rectangle(x_coord,y_coord,width,height,coreMaterial,EcoreGroup,'automesh',0,'meshsize',meshSize);
% Tooth 2
width = t_C;
height = w_C;
x_coord = t_T+t_Cu;
y_coord = w_I+g;
Draw_rectangle(x_coord,y_coord,width,height,coreMaterial,EcoreGroup,'automesh',0,'meshsize',meshSize);
% Tooth 3
width = t_T;
height = w_C;
x_coord = t_T+t_Cu+t_C+t_Cu;
y_coord = w_I+g;
Draw_rectangle(x_coord,y_coord,width,height,coreMaterial,EcoreGroup,'automesh',0,'meshsize',meshSize);
% Ecore back iron
width = 2*(t_T + t_Cu)+t_C;
height = w_I;
x_coord = 0;
y_coord = w_I+g+w_C;
Draw_rectangle(x_coord,y_coord,width,height,coreMaterial,EcoreGroup,'automesh',0,'meshsize',meshSize);

%% Coils
%In
width = t_Cu;
height = w_C;
x_coord = t_T;
y_coord = w_I+g;
Draw_rectangle(x_coord,y_coord, width, height, coilMaterial,coilGroup,'incircuit','A','turns',-turns,'automesh',1,'meshsize',meshSize);

%Out
width = t_Cu;
height = w_C;
x_coord = t_T+t_Cu+t_C;
y_coord = w_I+g;
Draw_rectangle(x_coord,y_coord, width, height, coilMaterial,coilGroup,'incircuit','A','turns',turns,'automesh',1,'meshsize',meshSize);


%% Airbox
drawLine(-t_T/2, -w_I/2, 2*(t_T +t_Cu)+t_C+t_T/2, -w_I/2);
drawLine(2*(t_T +t_Cu)+t_C+t_T/2, -w_I/2, 2*(t_T +t_Cu)+t_C+t_T/2, w_I/2+2*w_I+g+w_C);
drawLine(2*(t_T +t_Cu)+t_C+t_T/2, w_I/2+2*w_I+g+w_C, -t_T/2, w_I/2+2*w_I+g+w_C);
drawLine(-t_T/2, w_I/2+2*w_I+g+w_C, -t_T/2, -w_I/2);
mi_addblocklabel((2*(t_T +t_Cu)+t_C)/2,w_I+g/2);
mi_selectlabel((2*(t_T +t_Cu)+t_C)/2,w_I+g/2);
mi_setblockprop('Air',1,meshSize,'None', 0, airGroup,0);
mi_clearselected();

%% Analysis
angles = linspace(0,360,steps); % Angles
L_array = []; % Inductance array (let it be empty)
for i = 1:length(angles)
    kk = i;
    alpha_w = angles(i);
    I_a = I_pk.*cos(alpha_w*pi/180)+(I_pk/5).*cos(5*alpha_w*pi/180)+(I_pk/7).*cos(7*alpha_w*pi/180)+...
       (I_pk/23).*cos(23*alpha_w*pi/180); % Assume the 23rd harmonic is the sw freq harmonic
    mi_setcurrent('A',I_a);
    mi_analyze(1);
    mi_loadsolution();
    
   if alpha_w == 0
       nn = mo_numelements;
       B = zeros(floor(steps),nn);
       centroid = zeros(nn,1);
       a = zeros(nn,1);
       group_num = zeros(nn,1);
       
       for m = 1:nn
            elm = mo_getelement(m);
            centroid(m) = elm(4) + 1j*elm(5);
            a(m) = elm(6); % element area in the units used to draw the geometry
            group_num(m) = elm(7); % group number associated with the element
        end
            
            probinfo=mo_getprobleminfo; %get the problem info
              
   end
       for m = 1:nn
           if (group_num(m)==EcoreGroup || group_num(m)==IcoreGroup)
               p_c  = centroid(m);
                B(kk,m) = (mo_getb(real(p_c),imag(p_c))*[1;1j]);
           end
       end
%% Force on I core    
   mo_groupselectblock(IcoreGroup);
   force_array(kk)=mo_blockintegral(18);  
   mo_clearblock();
   
%% Inductance <ref: http://www.femm.info/wiki/InductanceExample>
   if (I_a ~= 0)
      if isempty(L_array)
       coilProp = mo_getcircuitproperties('A');
       L_array = coilProp(3)/coilProp(1);
       R_array = coilProp(2)/coilProp(1);
      else
          coilProp = mo_getcircuitproperties('A');
           L = coilProp(3)/coilProp(1);
           R = coilProp(2)/coilProp(1);
           L_array = [L_array, L];
           R_array = [R_array, R];
      end
   end   
   mo_close;
end
closefemm;
Res = mean(R_array);
Ind = mean(L_array);
force = force_array;
%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Post processing %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%
feaData.B = B; % Flux density in the core
feaData.L = probinfo(3); %depth [m]
feaData.units = probinfo(4); % length units
feaData.eleArea = a; %element area in [m^2]
feaData.groupNum = group_num; % group numbers
feaData.centroid = centroid; % centroid of mesh elements

b = feaData.B;
h = feaData.L;            % Length of the machine in the into-the-page direction
lengthunits = feaData.units;  % Length of drawing unit in meters
v = a*h*lengthunits^2; % This is because element area is in the units used to draw (which is mm^2 in this case)

%%%%%%%%%%%%%%%%%%%%%%% Compute Core Losses %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the square of the amplitude of each harmonic at the centroid of
% each element in the mesh. Matlab's built-in FFT function makes this easy.
ns=steps;
bxfft=abs(fft(real(b)))*(2/ns);
byfft=abs(fft(imag(b)))*(2/ns);
bsq=(bxfft.*bxfft) + (byfft.*byfft);
Frequency = f;
a= 1e6;
b= 6.13e7;
c= 2.05e6;
d= 6.1e-14;
% Make a vector representing the frequency associated with each harmonic
% The last half of the entries are zeroed out so that we don't count each
% harmonic twice--the upper half of the FFT a mirror of the lower half

w=0:(ns-1);
w=lowestHarmonic*Frequency*w.*(w<(ns/2));  
% Now, total core loss can be computed in one fell swoop...
% Dividing the result by cs corrects for the lamination stacking factor
g1=(feaData.groupNum==EcoreGroup);
B_tesla = nthroot(bsq,2);
B_gauss = B_tesla*10^4;
coreLoss=w'./(a./B_gauss.^3+b./B_gauss.^2.3+c./B_gauss.^1.65)+w'.^2.*d.*B_gauss.^2; %in mW/cm^3
losses.Ecore = coreLoss*1e3*(v.*g1); % Get the E core losses; Convert to W/m^3 and then to Watts.
losses.Ecore = sum(losses.Ecore);
g2=(feaData.groupNum==IcoreGroup);
losses.Icore = coreLoss*1e3*(v.*g2); % Get the I core losses; Convert to W/m^3 and then to Watts.
losses.Icore = sum(losses.Icore);
%%%%%%%%%%%%%%%%%%%%%%Compute Mass%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
I_corevolume = w_I*2*(t_T+t_Cu)+t_C*depth;
E_corevolume = depth*((w_E*2*(t_T+t_Cu)+t_C)-(2*t_Cu*w_C));
coreVolume = I_corevolume + E_corevolume;
coreMass = coreVolume*rho_core;
coilDia = 8.2514694*exp(-0.115943*gauge)*1e-3; % in [m]
meanLength = 2*(depth+t_C+t_Cu/2);
copperMass = rho_Cu*turns*meanLength*pi*(coilDia^2)/4;
mass = coreMass+copperMass;

volume.core = coreVolume;
volume.coil = turns*meanLength*pi*(coilDia^2)/4;