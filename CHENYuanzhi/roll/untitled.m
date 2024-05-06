[radius, cylinderAxis, cylinderOrin] = getCylinderParam('R.txt');


mcsPts = load('R.txt');
p0 = [0,0,0,0,0,1,39.5]
p=NIST_LevMar_Cylinder2(p0,mcsPts)














