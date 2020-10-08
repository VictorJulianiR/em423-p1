NumForcas = input("Qual o numero de forcas?\n", "s")
TamViga = input("Qual o tamanho da viga em metros?\n", "s")
ApoioPino = input("Onde está o apoio pino?\n", "s")

#Input forças
#F(1,2) = Angulo da força 1
#F(6,1) = Módulo da força 6
N_ForPontuais = input("Qual o número de forças pontuais?\n")
f = zeros(N_ForPontuais,3)
for i = 1:N_ForPontuais
  vectorr = input("[Intensidade, angulo, ponto]\n");
  f(i,1) = vectorr(1)
  f(i,2) = vectorr(2)
  f(i,3) = vectorr(3)
end


#Input torques
#T(1,1) = Direção do torque 1
#T(4,3) = Ponto de aplicação do torque 4
N_Torque = input("Quantos torques são?\n", "s");
T = zeros(N_Torque,3)
for (i = 1:N_Torque)
  vectorr = input("[Direção, intensidade, ponto]");
  T(i,1) = vectorr(1);
  T(i,2) = vectorr(2);
  T(i,3) = vectorr(3);
end

#Input Carregamentos
N_Carregamentos = input("Quantos os carregamentos distribuidos, 0 eh valido\n");
C = zeros(N_Carregamentos,2)
if N_Carregamentos>0
  MaiorGrauCarregamento = input("Qual maior grau do maior polinomio?")
  coefs = zeros(N_Carregamentos*MaiorGrauCarregamento)
  for (i = 1:N_Carregamentos)
    vectorr = input("[Pi, Pf, maior grau]\n");
    C(i,1) = vectorr(1);
    C(i,2) = vectorr(2);
    C(i,3) = vectorr(3)
    #Precisa de uma lógica de input do polinimo em si
    #grau(i) = C(i,3)
    #coefs(i) = input("[Coef1 Coef2 Coef3 ... CoefN]")
  end
endif

#Funções ou Módulos
function Fx = AnguloParaFx(F)
    #Fx(1) = parte X da força F(1)
    Fx = []

endfunction

function Fy = AnguloParaFy(F)
    #Fy(1) = parte X da força F(1)
    Fy = []
endfunction


function CarregamentoPontual = DistribuidoParaPontual(C)
  
endfunction

function Momento = CalcularMomento(Fx,Fy,T,CarregamentoPontual)

endfunction

function Equilbrio = CalculoEquilbrio()
  # Escopo? Como esse equilibrio vai ser apresentado?
endfunction

function DiagramaForcas = PlotDiagrama()
  #Escopo????
endfunction

function Report = GerarTextoRelatorio()
  #Escopo???
endfunction
