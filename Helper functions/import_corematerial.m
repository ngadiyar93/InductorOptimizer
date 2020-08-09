function import_corematerial(mat_name)

lam_thickness = 0; %Lamination thickness in [mm]
fill_factor = 1; %Lamination fill factor/stacking factor <=1; 1 for solid steel.

H = linspace(0, 100, 100); % H in [A/m]
H1 = linspace(100, 500, 11);
H = [H, H1];
H2 = linspace(500, 1500, 11);
H = [H,H2];
H3 = linspace(1500, 9500, 8);
H = [H,H3];
H = [H, 10000, 20000, 50000, 100000, 200000, 300000, 400000, 500000, 800000, 900000, 1000000, 3000000, 5000000, 9000000];

H_Oe = H.*0.0125663706;

m_u = 14;

a = 4.22e-3;	
b = 1.88;	
c = 3.99e2;	
d = 3.45e-1;	
e = 1.09e3;

B_G = m_u./(1./(H_Oe+a.*H_Oe.^b)+1./(c.*H_Oe.^d)+1./e);	

B_T = B_G.*(1/1e4);

mi_addmaterial(mat_name, 0, 0, 0, 0, 0, lam_thickness, 0, fill_factor, 0, 0, 0, 0, 0);


b = B_T;
h = H;
for i=1:length(b)
mi_addbhpoint(mat_name,b(i),h(i));
end
end