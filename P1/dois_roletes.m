clear;
clc;
disp("#####################################################################");
disp("REFERENCIAIS/CONVENÇÕES:");
disp("1a. Forças verticais são positivas no sentido positivo do eixo Y (para cima).");
disp("1b. Forças horizontais são positivas no sentido positivo do eixo X (para a direita).");
disp("1c. Torques são positivos no sentido positivo do eixo X (para a direita).");
disp("1d. Momentos são positivos no sentido anti-horário.");
disp("");
disp("2. Os referencias são adotados todos a partir do início da viga, ou seja, posição (0,0)")
# --(Afirmação acima) não necessariamente pois tem exercícios que só serão resolvidos
# mudando o referencial. Talvez somente para o apoio engastado esta afirmação é válida.
# --Supomos sempre que as vigas são ajustadas para que se localize no eixo x com inicio em (0,0)
# --Supomos também que os carregamentos distribuidos são sempre verticais de cima para baixo?
# --Podemos considerar a representação das forças verticais e horizontais atraves 
# do sinal positivo ou negativo da força ou pelo angulo correspondente. Qual é melhor?
# --Para marcar forças pontuais que são: 
# ----verticais para baixo: usa angulo 90
# ----verticais para baixo: usa angulo 270
# ----horizontais para esquerda: usa angulo 0
# ----horizontais para direita: usa angulo 180
# -- Considerando dois roletes, obrigatoriamente a resultante das forças externas verticais
# deve ser de cima para baixo e deve estar entre os dois roletes.     
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
  momentoCarregamento = polyval(integral, fim) - polyval(integral, ini);
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
      
      momentos(i, :) = [pos;intensidade];
      
      disp("Momento computado com sucesso!\n");
    endfor
  endif
endfunction


function forcasExternas = getForcas()
  numForcasPontuais = input("Quantas forças pontuais estão sendo aplicadas na viga: ");

  forcasExternas = zeros(numForcasPontuais,2); # [x, fy]

  if (numForcasPontuais > 0)
    disp("");
    disp("Para cada força, digite sua posição na viga e sua intensidade"); 
    disp(" ** Obrigatoriamente a resultante das forças externas verticais deve ser de cima para baixo e deve estar entre a posição dos dois roletes.");
    disp(" ** Se a intensidade é negativa, a força é aplicada verticalmente de baixo para cima");
    disp(" ** Para este problema, torques e forças no eixo x tem resultante 0.");
    disp("");
    for i = 1:numForcasPontuais
      disp(sprintf("Força %d\n", i));
      pos = input("Posição: ");
      intensidade = input("Intensidade: ");
      
      fy = intensidade
      
      forcasExternas(i,:) = [pos;fy]
      
      disp("Força computada com sucesso!");
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
pos_rolete_A = input ("Digite a posição do rolete 1: ");
pos_rolete_B = input ("Digite a posição do rolete 2: ");
forcas = getForcas()
#torques = getTorques()
momentos = getMomentos()
carregamentos = getCarregamentos()

###############################################
######## CÁLCULOS PARA O 2 ROLETES! ###########
###############################################

# 1. Equilibrio de forças na horizontal:
fx = 0.0; #Forças pontuais

printf("Fx: %f\n", fx);

# 2. Equilibrio de forças na vertical:
forcaCarregamento = 0;
for i = 1:rows(carregamentos) #Forças de carregamento distribuído
  forcaCarregamento = forcaCarregamento + calcForcaCarregamento(carregamentos(i,:));
endfor


fy = forcaCarregamento + sum(forcas(:,2)) #Forças pontuais
#fy = -fy #verificar tbm nos outros exe de apoio. Essa converção não é necessaria colocando o angulo correto.
printf("Fy: %f\n", fy);

# 3. Equilibrio de torques:
torque = 0.0;
#torque = -torque; # por que?
printf("Torque: %f\n", torque);

# 4. Equilibrio de momentos:
#Será escolhido o ponto de referencia sempre o rolete mais a esquerda.
if (pos_rolete_A < pos_rolete_B)
  pontoReferenciaMomento = pos_rolete_A
else
  pontoReferenciaMomento = pos_rolete_B
endif

# Momentos externos
momentoExterno = sum(momentos(:,2));

# Momento Carregamento
momentoCarregamento = 0
for i = 1:rows(carregamentos) #Momento do carregamento distribuído
  if carregamentos(i,2) <= pontoReferenciaMomento
    momentoCarregamento = momentoCarregamento + calcMomentoCarregamento(carregamento(i,:))
  else
    momentoCarregamento = momentoCarregamento - calcMomentoCarregamento(carregamento(i,:))
  endif
endfor

# Momento Forcas
momentoForcas = 0
for i = 1:rows(forcas) #Momento do carregamento distribuído
  if forcas(i,1) < pontoReferenciaMomento
    momentoForcas = momentoForcas + forcas(i,2)*abs(forcas(i,1)-pontoReferenciaMomento)
  elseif forcas(i,1) > pontoReferenciaMomento
    momentoForcas = momentoForcas - forcas(i,2)*abs(forcas(i,1)-pontoReferenciaMomento)
  endif
endfor

momentoTotal = momentoForcas + momentoCarregamento + momentoExterno


#Forças de apoio
if (pos_rolete_A < pos_rolete_B)
  Fyb = (-1*momentoTotal)/(pos_rolete_B-pos_rolete_A)
  Fya = -1*(Fyb + fy) 
else
  Fya = (-1*momentoTotal) / (pos_rolete_A-pos_rolete_B)
  Fyb = -1*(Fya + fy) 
endif

printf("Força de apoio para o relote 1: %f\n", Fya);
printf("Força de apoio para o rolete 2: %f\n", Fyb);


# TODO: DIAGRAMA DE ESFORÇOS SOLICITANTES