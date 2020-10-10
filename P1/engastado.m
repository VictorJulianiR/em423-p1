clear;
clc;
disp("#####################################################################");
disp("REFERENCIAIS/CONVENÇÕES:");
disp("1a. Forças verticais são positivas no sentido do eixo Y.");
disp("1b. Forças horizontais são positivas no sentido do eixo X.");
disp("1c. Torques são positivos no sentido do eixo X.");
disp("1d. Momentos são positivos no sentido anti-horário.");
disp("");
disp("2. Os referencias são adotados todos a partir do iniício da viga (ou seja, posição 0)")
disp("");
disp("3. Todas as unidades devem estar no SI menos os ângulos que estão em graus");
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
  numForcasPontuais = input("Quantas forças pontuais estão sendo aplicadas na viga: ");

  forcasExternas = zeros(numForcasPontuais,3); # [x, fx, fy]

  if (numForcasPontuais > 0)
    disp("");
    disp("Para cada força, digite sua posição na viga, intensidade, ângulo em graus");
    for i = 1:numForcasPontuais
      disp(sprintf("Força %d\n", i));
      pos = input("Posição: ");
      intensidade = input("Intensidade: ");
      angulo = input("Ângulo: ");
      
      fx = intensidade*cos(deg2rad(angulo));
      fy = intensidade*sin(deg2rad(angulo));
      
      forcasExternas(i,:) = [pos;fx;fy]
      
      disp("Força computada com sucesso!");
    endfor
  endif
endfunction

function torques = getTorques()
  numTorques = input("Quantos torques estao sendo aplicados na viga: ");

  torques = zeros(numTorques,2); # [x, intensidade]

  if (numTorques > 0)
    disp("");
    disp("Para cada torque, digite sua posição e sua intensidade - lembrando que se a intensidade é negativa, o torque é tido no sentido oposto do eixo X.");
    for i = 1:numTorques
      disp(sprintf("Torque %d\n", i));
      pos = input("Posição: ");
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
    disp("Para cada momento, digite sua posição e sua intensidade - lembrando que se a intensidade é negativa, o momento é tido no sentido horário.");
    for i = 1:numMomentos
      disp(sprintf("Momento %d\n", i));
      pos = input("Posição: ");
      intensidade = input("Intensidade: ");
      
      momentos(i, :) = [pos;intensidade]
      
      disp("Momento computado com sucesso!");
    endfor
  endif
endfunction


function carregamentos = getCarregamentos()
  numCarregamentos = input("Quantos carregamentos distribuídos estão sendo aplicados na viga: ");
  n = input("Digite o grau máximo 'n' da função de carregamento: ")
  
  carregamentos = zeros(numCarregamentos, n+3); # [posIni, posFim, coefs]

  if (numCarregamentos > 0)
    disp("");
    disp("Para cada carregamento, digite as suas posições inicial e final e sua função polinomial (em N/m)");
    for i = 1:numCarregamentos
      disp(sprintf("Carregamento %d\n", i));
      posIni = input("Posição inicial: ");
      posFim = input("Posição final: ");
      coefs = input("Coeficientes (seguindo o padrão) [an;an-1;...;a1;a0]:")
      
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
######## CÁLCULOS PARA O ENGASTADO! ###########
###############################################

# 1. Equilibrio de forças na horizontal:
fx = sum(forcas(:,2)); #Forças pontuais
fy = -fx
printf("Fx: %f\n", fx);

# 2. Equilibrio de forças na vertical:
fy = 0;

for i = 1:rows(carregamentos) #Forças de carregamento distribuído
  forcaCarregamento = calcForcaCarregamento(carregamentos(i,:))
  fy = fy + forcaCarregamento;
endfor

fy = fy + sum(forcas(:,3)); #Forças pontuais
fy = -fy
printf("Fy: %f\n", fy);

# 3. Equilibrio de torques:
torque = sum(torques(:,2));
torque = -torque
printf("Torque: %f\n", torque);

# 4. Equilibrio de momentos:
momento = 0;

for i = 1:rows(carregamentos) #Momento do carregamento distribuído
  momentoCarregamento = calcMomentoCarregamento(carregamentos(i,:))
  momento = momento + momentoCarregamento;
endfor

# Momentos externos
momento = momento + sum(momentos(:,2)); #Forças pontuais

#Momentos gerados pelas forças externas pontuais
momento = dot(forcas(:,1), forcas(:, 3))

momento = -momento
printf("Momento: %f\n", momento);

# TODO: DIAGRAMA DE ESFORÇOS SOLICITANTES


