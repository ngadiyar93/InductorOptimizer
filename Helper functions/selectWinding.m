function winding = selectWinding(chromosome, dimensions, settings)
% SELECTWINDING is used to select the winding configuration

window_area = dimensions.t_Cu*dimensions.w_C;
available_Area = settings.k_p*window_area;
AWG_raw = chromosome(8);
AWG_int = floor(AWG_raw); % [#] --> Whole number portion of AWG
% Check that the AWG is even.
    if mod(AWG_int, 2) % If the AWG is odd ...
        AWG_int = AWG_int - 1; % then make the AWG even
    end
    
coilDia = 8.2514694*exp(-0.115943*AWG_int);
strandArea = pi*(coilDia^2)/4;

if (settings.I_pk/strandArea)<settings.J
    layers = 1;
else
    layers = ceil((settings.I_pk/strandArea)/settings.J);
end

turns = availableArea/(layers*strandArea);
    
winding.N_t = turns;
winding.gauge = AWG_int;

end