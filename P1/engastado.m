clear;
clc;
disp("#####################################################################");
disp("REFERENCIAIS/CONVEN��ES:");
disp("1a. For�as verticais s�o positivas no sentido do eixo Y.");
disp("1b. For�as horizontais s�o positivas no sentido do eixo X.");
disp("1c. Torques s�o positivos no sentido do eixo X.");
disp("1d. Momentos s�o positivos no sentido anti-hor�rio.");
disp("");
disp("2. Os referencias s�o adotados todos a partir do ini�cio da viga (ou seja, posi��o 0)")
disp("");
disp("3. Todas as unidades devem estar no SI menos os �ngulos que est�o em graus");
disp("#####################################################################\n");

function forcaCarregamento = calcForcaCarregamento(carregamento)
  ini = carregamento(1);
  fim = carregamento(2);
  coefs = transpose(carregamento(3:end));
  integral = polyint(coefs);
  forcaCarregamento = polyval(integral, fim) - polyval(integral, ini);
endfunction

function momentoCarregamento = calcMomentoCarregamento(carregamento)
  ini = carregamento(1);
  fim = carregamento(2);
  coefs = transpose(carregamento(3:end));
  coefs = [coefs, 0]
  integral = polyint(coefs);
  forcaCarregamento = polyval(integral, fim) - polyval(integral, ini);
endfunction


function forcasExternas = getForcas()
  numForcasPontuais = input("Quantas for�as pontuais est�o sendo aplicadas na viga: ");

  forcasExternas = zeros(numForcasPontuais,3); # [x, fx, fy]

  if (numForcasPontuais > 0)
    disp("");
    disp("Para cada for�a, digite sua posi��o na viga, intensidade, �ngulo em graus");
    for i = 1:numForcasPontuais
      disp(sprintf("For�a %d\n", i));
      pos = input("Posi��o: ");
      intensidade = input("Intensidade: ");
      angulo = input("�ngulo: ");
      
      fx = intensidade*cos(deg2rad(angulo));
      fy = intensidade*sin(deg2rad(angulo));
      
      forcasExternas(i,:) = [pos;fx;fy]
      
      disp("For�a computada com sucesso!");
    endfor
  endif
endfunction

function torques = getTorques()
  numTorques = input("Quantos torques estao sendo aplicados na viga: ");

  torques = zeros(numTorques,2); # [x, intensidade]

  if (numTorques > 0)
    disp("");
    disp("Para cada torque, digite sua posi��o e sua intensidade - lembrando que se a intensidade � negativa, o torque � tido no sentido oposto do eixo X.");
    for i = 1:numTorques
      disp(sprintf("Torque %d\n", i));
      pos = input("Posi��o: ");
      intensidade = input("Intensidade: ");
      
      torques(i, :) = [pos;intensidade]
      
      disp("Torque computado com sucesso!");
    endfor
  endif
endfunction

function momentos = getMomentos()
  numMomentos = input("Quantos momentos estao sendo aplicados na viga: ");

  momentos = zeros(numMomentos,2); # [x, intensidade]

  if (numMomentos > 0)
    disp("");
    disp("Para cada momento, digite sua posi��o e sua intensidade - lembrando que se a intensidade � negativa, o momento � tido no sentido hor�rio.");
    for i = 1:numMomentos
      disp(sprintf("Momento %d\n", i));
      pos = input("Posi��o: ");
      intensidade = input("Intensidade: ");
      
      momentos(i, :) = [pos;intensidade]
      
      disp("Momento computado com sucesso!");
    endfor
  endif
endfunction


function carregamentos = getCarregamentos()
  numCarregamentos = input("Quantos carregamentos distribu�dos est�o sendo aplicados na viga: ");
  n = input("Digite o grau m�ximo 'n' da fun��o de carregamento: ")
  
  carregamentos = zeros(numCarregamentos, n+3); # [posIni, posFim, coefs]

  if (numCarregamentos > 0)
    disp("");
    disp("Para cada carregamento, digite as suas posi��es inicial e final e sua fun��o polinomial (em N/m)");
    for i = 1:numCarregamentos
      disp(sprintf("Carregamento %d\n", i));
      posIni = input("Posi��o inicial: ");
      posFim = input("Posi��o final: ");
      coefs = input("Coeficientes (seguindo o padr�o) [an;an-1;...;a1;a0]:")
      
      carregamentos(i, :) = [posIni;posFim;coefs]
      
      disp("Carregamento computado com sucesso.");
    endfor
  endif
endfunction

tamanhoViga = input("Digite o tamanho da viga: ");

forcas = getForcas()
torques = getTorques()
momentos = getMomentos()
carregamentos = getCarregamentos()

###############################################
######## C�LCULOS PARA O ENGASTADO! ###########
###############################################

# 1. Equilibrio de for�as na horizontal:
fx = sum(forcas(:,2)); #For�as pontuais
fy = -fx
printf("Fx: %f\n", fx);

# 2. Equilibrio de for�as na vertical:
fy = 0;

for i = 1:rows(carregamentos) #For�as de carregamento distribu�do
  forcaCarregamento = calcForcaCarregamento(carregamentos(i,:))
  fy = fy + forcaCarregamento;
endfor

fy = fy + sum(forcas(:,3)); #For�as pontuais
fy = -fy
printf("Fy: %f\n", fy);

# 3. Equilibrio de torques:
torque = sum(torques(:,2));
torque = -torque
printf("Torque: %f\n", torque);

# 4. Equilibrio de momentos:
momento = 0;

for i = 1:rows(carregamentos) #Momento do carregamento distribu�do
  momentoCarregamento = calcMomentoCarregamento(carregamentos(i,:))
  momento = momento + momentoCarregamento;
endfor

# Momentos externos
momento = momento + sum(momentos(:,2)); #For�as pontuais

#Momentos gerados pelas for�as externas pontuais
momento = dot(forcas(:,1), forcas(:, 3))

momento = -momento
printf("Momento: %f\n", momento);

# TODO: DIAGRAMA DE ESFOR�OS SOLICITANTES


