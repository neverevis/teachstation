/*
 * Questionário gamificado do TeachStation.
 *
 * Três formatos: ASSOCIACAO (conectar frase e palavra), PREENCHIMENTO (completar
 * a frase com verbos) e MULTIPLA_ESCOLHA. Toda a navegação acontece sem recarregar
 * a página: o JavaScript conversa com a API JSON (QuizGamificadoController) e a
 * correção é feita no servidor. O navegador nunca recebe o gabarito antes de a
 * questão ser resolvida.
 */
(function () {
    'use strict';

    var raiz = document.getElementById('quiz');
    var palco = document.getElementById('quizPalco');
    if (!raiz || !palco) {
        return;
    }

    var API = raiz.dataset.api;
    var FASE = raiz.dataset.fase;
    var URL_MAPA = raiz.dataset.mapa;

    var ROTULOS = {
        ASSOCIACAO: 'Conecte a frase com a palavra',
        PREENCHIMENTO: 'Preencha a frase',
        MULTIPLA_ESCOLHA: 'Múltipla escolha'
    };
    var LETRAS = ['A', 'B', 'C', 'D'];
    var SVG_NS = 'http://www.w3.org/2000/svg';

    var dados = null;      // fase carregada do servidor
    var indice = 0;        // questão exibida
    var ocupado = false;   // true enquanto uma requisição está em andamento
    var edicao = {};       // respostas em edição, por id de questão (preservadas ao navegar)
    var ui = {};           // referências aos elementos da questão exibida
    var ponteiro = null;   // posição do mouse enquanto uma ligação está sendo feita
    var observador = null; // acompanha o tamanho da área de associação
    var progressoAnterior = null; // porcentagem da barra na tela anterior (a barra anima daí até o novo valor)

    // ---------- Utilidades ----------

    function el(tag, props, filhos) {
        var e = document.createElement(tag);
        Object.keys(props || {}).forEach(function (chave) {
            var valor = props[chave];
            if (valor === null || valor === undefined || valor === false) {
                return;
            }
            if (chave === 'class') {
                e.className = valor;
            } else if (chave === 'text') {
                e.textContent = valor;
            } else if (chave.indexOf('on') === 0) {
                e.addEventListener(chave.slice(2), valor);
            } else {
                e.setAttribute(chave, valor === true ? '' : valor);
            }
        });
        (filhos || []).forEach(function (filho) {
            if (filho) {
                e.appendChild(typeof filho === 'string' ? document.createTextNode(filho) : filho);
            }
        });
        return e;
    }

    function svgEl(tag, atributos) {
        var e = document.createElementNS(SVG_NS, tag);
        Object.keys(atributos || {}).forEach(function (chave) {
            e.setAttribute(chave, atributos[chave]);
        });
        return e;
    }

    function copia(objeto) {
        return JSON.parse(JSON.stringify(objeto || {}));
    }

    function atual() {
        return dados.questoes[indice];
    }

    // Resolvida (acertou ou esgotou as tentativas) ou aguardando resposta: a resposta fica travada
    function bloqueada(q) {
        return q.estado.resolvida || ocupado;
    }

    function pararAudio() {
        if ('speechSynthesis' in window) {
            window.speechSynthesis.cancel();
        }
    }

    function textoDe(lista, id) {
        for (var i = 0; i < lista.length; i++) {
            if (lista[i].id === id) {
                return lista[i].texto;
            }
        }
        return '';
    }

    function chaveDoValor(mapa, valor) {
        var chaves = Object.keys(mapa);
        for (var i = 0; i < chaves.length; i++) {
            if (mapa[chaves[i]] === valor) {
                return chaves[i];
            }
        }
        return null;
    }

    // ---------- Comunicação com o servidor ----------

    function chamar(metodo, url, corpo) {
        var opcoes = {
            method: metodo,
            headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
            credentials: 'same-origin'
        };
        if (corpo) {
            opcoes.body = JSON.stringify(corpo);
        }

        return fetch(url, opcoes).then(function (resposta) {
            return resposta.text().then(function (texto) {
                var dadosResposta = null;
                try {
                    dadosResposta = texto ? JSON.parse(texto) : null;
                } catch (e) {
                    dadosResposta = null;
                }

                if (!resposta.ok) {
                    var mensagem = dadosResposta && dadosResposta.erro;
                    if (!mensagem) {
                        mensagem = resposta.status === 403
                            ? 'Entre como aluno para responder ao questionário.'
                            : 'Não foi possível concluir a ação. Tente novamente.';
                    }
                    var erro = new Error(mensagem);
                    erro.status = resposta.status;
                    throw erro;
                }
                return dadosResposta;
            });
        }, function () {
            throw new Error('Sem conexão com o servidor. Verifique a internet e tente novamente.');
        });
    }

    // ---------- Telas de carregamento, erro e resultado ----------

    function limparPalco() {
        if (observador) {
            observador.disconnect();
            observador = null;
        }
        ui = {};
        ponteiro = null;
        pararAudio(); // trocar de tela (avançar, finalizar, recarregar) interrompe a leitura em voz alta
        palco.textContent = '';
        palco.removeAttribute('aria-busy');
    }

    function mostrarCarregando(mensagem) {
        limparPalco();
        palco.setAttribute('aria-busy', 'true');
        palco.appendChild(el('p', {class: 'quiz-aviso-tela', role: 'status', text: mensagem || 'Carregando as questões…'}));
    }

    // Fase bloqueada (403): não adianta tentar de novo, só voltar ao mapa
    function mostrarErro(mensagem, tentarDeNovo, bloqueada) {
        limparPalco();
        palco.appendChild(el('div', {class: 'quiz-aviso-tela quiz-erro', role: 'alert'}, [
            el('p', {text: '😕 ' + mensagem}),
            bloqueada
                ? el('a', {class: 'botao-confirmar', href: URL_MAPA, text: 'Voltar ao mapa'})
                : el('button', {type: 'button', class: 'botao-proxima', text: 'Tentar novamente', onclick: tentarDeNovo})
        ]));
    }

    function carregar(nova) {
        mostrarCarregando();
        chamar('GET', API + '/fases/' + encodeURIComponent(FASE) + (nova ? '?nova=true' : ''))
            .then(function (fase) {
                dados = fase;
                edicao = {};
                fase.questoes.forEach(prepararEdicao);

                var primeiraPendente = -1;
                for (var i = 0; i < fase.questoes.length; i++) {
                    if (!fase.questoes[i].estado.resolvida) {
                        primeiraPendente = i;
                        break;
                    }
                }
                indice = primeiraPendente === -1 ? fase.questoes.length - 1 : primeiraPendente;
                progressoAnterior = null; // ao abrir ou recarregar, a barra aparece direto no valor certo
                renderQuestao();
            })
            .catch(function (erro) {
                mostrarErro(erro.message, function () {
                    carregar(nova);
                }, erro.status === 403);
            });
    }

    function finalizar() {
        if (ocupado) {
            return;
        }
        ocupado = true;
        atualizarAcoes();

        chamar('GET', API + '/fases/' + encodeURIComponent(FASE) + '/resultado')
            .then(function (resultado) {
                ocupado = false;
                renderResultado(resultado);
            })
            .catch(function (erro) {
                ocupado = false;
                atualizarAcoes();
                mostrarMensagem(erro.message);
            });
    }

    function renderResultado(resultado) {
        limparPalco();

        var lista = el('ol', {class: 'quiz-resultado-lista'});
        resultado.itens.forEach(function (item) {
            lista.appendChild(el('li', {class: item.acertou ? 'ok' : 'erro'}, [
                el('span', {class: 'quiz-resultado-icone', text: item.acertou ? '✔ Acertou' : '✖ Errou'}),
                el('span', {class: 'quiz-resultado-texto', text: 'Questão ' + item.ordem + ' · ' + ROTULOS[item.tipo]}),
                el('span', {class: 'quiz-resultado-pontos', text: item.pontosObtidos + ' / ' + item.pontosMaximos + ' pts'})
            ]));
        });

        palco.appendChild(barraProgresso(100));
        palco.appendChild(el('article', {class: 'card-questao quiz-resultado'}, [
            el('h2', {id: 'quizTituloResultado', tabindex: '-1', text: '🏆 Fase concluída!'}),
            el('p', {class: 'quiz-placar'}, [
                el('strong', {text: String(resultado.acertos)}),
                ' de ' + resultado.totalQuestoes + (resultado.totalQuestoes === 1 ? ' questão correta' : ' questões corretas')
            ]),
            el('p', {class: 'quiz-pontos', text: 'Você fez ' + resultado.pontos + ' de ' + resultado.pontosMaximos + ' pontos.'}),
            lista,
            el('div', {class: 'acoes-quiz'}, [
                el('a', {class: 'botao-confirmar', href: URL_MAPA, text: 'Voltar ao mapa'}),
                el('button', {
                    type: 'button', class: 'botao-proxima', text: 'Jogar novamente ↻',
                    onclick: function () {
                        carregar(true);
                    }
                }),
                resultado.proximaFase ? el('a', {
                    class: 'botao-proxima botao-proxima-fase',
                    href: URL_MAPA + '/level' + resultado.proximaFase,
                    text: 'Avançar para a próxima fase →'
                }) : null
            ])
        ]));

        document.getElementById('quizTituloResultado').focus();
    }

    // ---------- Estado de edição de cada questão ----------

    function prepararEdicao(q) {
        var e = {pares: {}, lacunas: {}, opcao: null, marcas: {}, pendente: null, ativa: null, mostrarFeedback: false};
        var ultima = q.estado.ultimaResposta;

        if (ultima) {
            e.pares = copia(ultima.pares);
            e.lacunas = copia(ultima.lacunas);
            e.opcao = ultima.opcao || null;
            e.mostrarFeedback = true;
        }
        if (q.tipo !== 'MULTIPLA_ESCOLHA' && q.estado.detalhes) {
            e.marcas = copia(q.estado.detalhes);
        }
        edicao[q.id] = e;
    }

    // ---------- Estrutura comum da questão ----------

    // A barra nasce na largura da tela anterior e, no quadro seguinte, vai para o novo valor:
    // o CSS (transition em .progresso-atual) faz a animação suave em vez de um salto.
    function barraProgresso(porcentagem) {
        var inicio = progressoAnterior === null ? porcentagem : progressoAnterior;
        var preenchimento = el('div', {class: 'progresso-atual', style: 'width: ' + inicio + '%;'});

        if (inicio !== porcentagem) {
            window.requestAnimationFrame(function () {
                window.requestAnimationFrame(function () {
                    preenchimento.style.width = porcentagem + '%';
                });
            });
        }
        progressoAnterior = porcentagem;

        return el('div', {class: 'area-progresso'}, [
            el('div', {
                class: 'barra-progresso', role: 'progressbar', 'aria-label': 'Progresso do questionário',
                'aria-valuemin': '0', 'aria-valuemax': '100', 'aria-valuenow': String(porcentagem)
            }, [preenchimento])
        ]);
    }

    function renderQuestao() {
        limparPalco();

        var q = atual();
        var total = dados.questoes.length;
        var numero = q.ordem < 10 ? '0' + q.ordem : String(q.ordem);
        var ehUltima = indice === total - 1;

        ui.q = q;
        // O progresso conta as questões que o aluno já passou (acertando ou errando): sobe ao avançar
        ui.progresso = barraProgresso(Math.round((indice * 100) / total));
        ui.tentativas = el('strong');
        ui.area = el('div', {class: 'quiz-area'});
        ui.dica = el('p', {class: 'quiz-dica', id: 'quizDica', role: 'status'});
        ui.feedback = el('div', {class: 'quiz-feedback'});
        ui.confirmar = el('button', {
            type: 'button', class: 'botao-confirmar', text: 'Confirmar resposta',
            'aria-describedby': 'quizDica', onclick: confirmar
        });
        ui.avancar = el('button', {
            type: 'button', class: 'botao-proxima', onclick: ehUltima ? finalizar : avancar
        });
        ui.rotuloAvancar = ehUltima ? 'Finalizar 🏁' : 'Avançar →';

        var cartao = el('article', {class: 'card-questao quiz-card'}, [
            el('span', {class: 'numero-questao', text: 'QUESTÃO ' + numero + ' · ' + ROTULOS[q.tipo]}),
            textoApoio(q),
            el('button', {type: 'button', class: 'botao-ouvir', text: '🔊 Ouvir a questão', onclick: function () {
                ouvir(q);
            }}),
            el('h3', {id: 'quizEnunciado', tabindex: '-1', text: q.enunciado}),
            ui.area,
            ui.dica,
            ui.feedback,
            el('div', {class: 'acoes-quiz'}, [
                el('div', {class: 'acoes-quiz-esquerda'}, [ui.confirmar]),
                ui.avancar
            ])
        ]);

        palco.appendChild(el('div', {class: 'informacoes-avaliacao'}, [
            el('div', {class: 'informacao-questao'}, [
                el('span', {text: 'Questão'}),
                el('strong', {text: q.ordem + ' de ' + total})
            ]),
            el('div', {class: 'informacao-tempo'}, [el('span', {'aria-hidden': 'true', text: '🎯'}), ui.tentativas])
        ]));
        palco.appendChild(ui.progresso);
        palco.appendChild(cartao);

        if (q.tipo === 'ASSOCIACAO') {
            montarAssociacao(q);
        } else if (q.tipo === 'PREENCHIMENTO') {
            montarPreenchimento(q);
        } else {
            montarMultiplaEscolha(q);
        }

        atualizar();
        document.getElementById('quizEnunciado').focus({preventScroll: true});
        raiz.scrollIntoView({block: 'start'});
    }

    function textoApoio(q) {
        if (!q.textoApoio) {
            return null;
        }
        return el('div', {class: 'texto-apoio'}, [
            el('p', {class: 'texto-apoio-titulo', text: '📖 Leia com calma'}),
            el('p', {class: 'texto-apoio-corpo', text: q.textoApoio})
        ]);
    }

    function avancar() {
        if (ocupado || !atual().estado.resolvida || indice >= dados.questoes.length - 1) {
            return;
        }
        indice++;
        renderQuestao();
    }

    // Atualiza tudo o que depende do estado da questão exibida
    function atualizar() {
        var q = atual();
        if (q.tipo === 'ASSOCIACAO') {
            atualizarAssociacao();
        } else if (q.tipo === 'PREENCHIMENTO') {
            atualizarPreenchimento();
        } else {
            atualizarMultiplaEscolha();
        }
        atualizarTentativas();
        atualizarDica();
        atualizarFeedback();
        atualizarAcoes();
    }

    function atualizarTentativas() {
        var estado = atual().estado;
        var restantes = estado.tentativasMax - estado.tentativasUsadas;
        if (estado.tentativasMax === 1) {
            ui.tentativas.textContent = 'Uma tentativa';
        } else if (estado.resolvida) {
            ui.tentativas.textContent = 'Questão resolvida';
        } else {
            ui.tentativas.textContent = 'Tentativas restantes: ' + restantes;
        }
    }

    function andamentoDaResposta(q) {
        var e = edicao[q.id];
        if (q.tipo === 'ASSOCIACAO') {
            return {feitos: Object.keys(e.pares).length, total: q.conteudo.esquerda.length};
        }
        if (q.tipo === 'PREENCHIMENTO') {
            return {feitos: Object.keys(e.lacunas).length, total: lacunasDe(q).length};
        }
        return {feitos: e.opcao ? 1 : 0, total: 1};
    }

    function atualizarDica() {
        var q = atual();
        var progresso = andamentoDaResposta(q);
        var faltam = progresso.total - progresso.feitos;
        var texto = '';

        if (ocupado) {
            texto = 'Verificando a resposta…';
        } else if (!q.estado.resolvida) {
            if (q.tipo === 'ASSOCIACAO') {
                texto = faltam > 0
                    ? 'Toque no ponto de uma frase e depois no ponto da palavra. Faltam ' + faltam + ' ligações.'
                    : 'Tudo ligado! Confirme a sua resposta.';
            } else if (q.tipo === 'PREENCHIMENTO') {
                texto = faltam > 0
                    ? 'Toque em um verbo para colocá-lo na lacuna. Faltam ' + faltam + ' lacunas.'
                    : 'Tudo preenchido! Confirme a sua resposta.';
            } else {
                texto = faltam > 0
                    ? 'Escolha uma alternativa. Você pode trocar de ideia antes de confirmar.'
                    : 'Alternativa escolhida. Confirme a sua resposta ou escolha outra.';
            }
        }
        ui.dica.textContent = texto;
    }

    function mostrarMensagem(mensagem) {
        ui.feedback.textContent = '';
        ui.feedback.appendChild(el('div', {class: 'card-feedback erro', role: 'alert'}, [
            el('p', {text: '⚠ ' + mensagem})
        ]));
    }

    function atualizarAcoes() {
        var q = atual();
        var progresso = andamentoDaResposta(q);

        ui.confirmar.disabled = ocupado || q.estado.resolvida || progresso.feitos < progresso.total;
        ui.confirmar.textContent = ocupado ? 'Verificando…' : 'Confirmar resposta';
        ui.avancar.disabled = ocupado || !q.estado.resolvida;
        ui.avancar.textContent = ui.rotuloAvancar;
    }

    // ---------- Feedback depois de responder ----------

    function atualizarFeedback() {
        var q = atual();
        var e = edicao[q.id];
        var estado = q.estado;

        ui.feedback.textContent = '';
        if (estado.tentativasUsadas === 0 || !e.mostrarFeedback) {
            return;
        }

        var corretos = 0;
        var total = 0;
        if (estado.detalhes) {
            Object.keys(estado.detalhes).forEach(function (chave) {
                total++;
                if (estado.detalhes[chave]) {
                    corretos++;
                }
            });
        }

        var cartao;
        if (estado.acertou) {
            cartao = el('div', {class: 'card-feedback sucesso'}, [
                el('p', {}, [el('strong', {text: '🎉 Correto! '}), 'Você ganhou ' + estado.pontosObtidos + ' pontos.'])
            ]);
        } else if (estado.resolvida) {
            cartao = el('div', {class: 'card-feedback erro'}, [
                el('p', {}, [el('strong', {text: '💪 Quase lá! '}), 'Veja a resposta correta:']),
                respostaCorreta(q)
            ]);
        } else {
            var restantes = estado.tentativasMax - estado.tentativasUsadas;
            var unidade = total === 1 ? 'lacuna correta' : 'lacunas corretas';
            cartao = el('div', {class: 'card-feedback erro'}, [
                el('p', {}, [
                    el('strong', {text: '🔁 Ainda não está certo. '}),
                    corretos + ' de ' + total + ' ' + unidade + '. Corrija e confirme de novo. Tentativas restantes: ' + restantes + '.'
                ])
            ]);
        }

        if (estado.resolvida && estado.explicacao) {
            cartao.appendChild(el('p', {class: 'quiz-explicacao', text: estado.explicacao}));
        }
        ui.feedback.appendChild(cartao);
    }

    // Mostra a resposta correta (só existe no estado quando a questão foi resolvida)
    function respostaCorreta(q) {
        var gabarito = q.estado.gabarito;

        if (q.tipo === 'ASSOCIACAO') {
            var lista = el('ul', {class: 'quiz-gabarito'});
            q.conteudo.esquerda.forEach(function (frase) {
                lista.appendChild(el('li', {}, [
                    frase.texto + ' → ',
                    el('strong', {text: textoDe(q.conteudo.direita, gabarito[frase.id])})
                ]));
            });
            return lista;
        }

        if (q.tipo === 'PREENCHIMENTO') {
            var partes = q.conteudo.frase.split(/\{(\d+)\}/);
            var frase = el('p', {class: 'quiz-gabarito'});
            partes.forEach(function (parte, i) {
                if (i % 2 === 0) {
                    frase.appendChild(document.createTextNode(parte));
                } else {
                    frase.appendChild(el('strong', {text: textoDe(q.conteudo.opcoes, gabarito[parte])}));
                }
            });
            return frase;
        }

        return el('p', {class: 'quiz-gabarito'}, [
            el('strong', {text: gabarito.correta + ') ' + textoDe(q.conteudo.opcoes, gabarito.correta)})
        ]);
    }

    // ---------- Envio da resposta ----------

    function confirmar() {
        var q = atual();
        var e = edicao[q.id];
        if (q.tipo === 'ASSOCIACAO') {
            enviar(q, {pares: e.pares});
        } else if (q.tipo === 'PREENCHIMENTO') {
            enviar(q, {lacunas: e.lacunas});
        } else {
            enviar(q, {opcao: e.opcao});
        }
    }

    function enviar(q, corpo) {
        if (ocupado || bloqueada(q)) {
            return;
        }
        ocupado = true;
        atualizar();

        chamar('POST', API + '/questoes/' + encodeURIComponent(q.id) + '/resposta', corpo)
            .then(function (resposta) {
                var e = edicao[q.id];
                q.estado = resposta.estado;
                e.mostrarFeedback = true;
                e.marcas = q.tipo === 'MULTIPLA_ESCOLHA' ? {} : copia(resposta.estado.detalhes);
                if (q.tipo === 'MULTIPLA_ESCOLHA') {
                    e.opcao = resposta.estado.ultimaResposta.opcao;
                }
                ocupado = false;
                if (atual() === q) {
                    atualizar();
                    if (q.estado.resolvida) {
                        ui.avancar.focus();
                    }
                }
            })
            .catch(function (erro) {
                // A resposta continua na tela: nada é apagado quando a comunicação falha
                ocupado = false;
                if (atual() === q) {
                    atualizar();
                    mostrarMensagem(erro.message);
                    if (erro.status === 409) {
                        ui.feedback.appendChild(el('button', {
                            type: 'button', class: 'botao-confirmar', text: 'Atualizar questões',
                            onclick: function () {
                                carregar(false);
                            }
                        }));
                    }
                }
            });
    }

    // ---------- Formato 1: conectar a frase com a palavra ----------

    function montarAssociacao(q) {
        var c = q.conteudo;
        var listaEsq = el('ul', {class: 'assoc-coluna assoc-esq', 'aria-label': 'Frases'});
        var listaDir = el('ul', {class: 'assoc-coluna assoc-dir', 'aria-label': 'Palavras'});

        ui.itens = {esq: {}, dir: {}};
        ui.pontos = {esq: {}, dir: {}};

        c.esquerda.forEach(function (item) {
            var ponto = el('button', {
                type: 'button', class: 'assoc-ponto',
                'aria-label': 'Ponto de conexão da frase: ' + item.texto
            });
            var li = el('li', {class: 'assoc-item assoc-item-esq', onclick: function () {
                clicarPonto('esq', item.id);
            }}, [
                el('span', {class: 'assoc-texto', text: item.texto}),
                el('span', {class: 'assoc-marca', 'aria-hidden': 'true'}),
                ponto
            ]);
            ui.itens.esq[item.id] = li;
            ui.pontos.esq[item.id] = ponto;
            listaEsq.appendChild(li);
        });

        c.direita.forEach(function (item) {
            var ponto = el('button', {
                type: 'button', class: 'assoc-ponto',
                'aria-label': 'Ponto de conexão da palavra: ' + item.texto
            });
            var li = el('li', {class: 'assoc-item assoc-item-dir', onclick: function () {
                clicarPonto('dir', item.id);
            }}, [
                ponto,
                el('span', {class: 'assoc-texto', text: item.texto}),
                el('span', {class: 'assoc-marca', 'aria-hidden': 'true'})
            ]);
            ui.itens.dir[item.id] = li;
            ui.pontos.dir[item.id] = ponto;
            listaDir.appendChild(li);
        });

        ui.svg = svgEl('svg', {class: 'assoc-linhas', 'aria-hidden': 'true', focusable: 'false'});
        ui.wrap = el('div', {class: 'assoc'}, [listaEsq, listaDir, ui.svg]);

        ui.wrap.addEventListener('pointermove', function (evento) {
            var caixa = ui.wrap.getBoundingClientRect();
            ponteiro = {x: evento.clientX - caixa.left, y: evento.clientY - caixa.top};
            if (edicao[q.id].pendente) {
                desenharLinhas();
            }
        });
        ui.wrap.addEventListener('pointerleave', function () {
            ponteiro = null;
            desenharLinhas();
        });

        ui.area.appendChild(ui.wrap);

        // As linhas acompanham os pontos quando o layout muda de tamanho
        if (window.ResizeObserver) {
            observador = new ResizeObserver(desenharLinhas);
            observador.observe(ui.wrap);
        }
    }

    function clicarPonto(lado, id) {
        var q = atual();
        if (bloqueada(q)) {
            return;
        }
        var e = edicao[q.id];

        if (lado === 'esq') {
            if (e.pares[id] !== undefined) {
                desfazerLigacao(e, id);
            } else {
                e.pendente = e.pendente === id ? null : id;
            }
        } else {
            var esquerdaLigada = chaveDoValor(e.pares, id);
            var pendente = e.pendente;
            if (pendente !== null) {
                // Cada palavra recebe uma única frase: uma ligação anterior da palavra é desfeita
                if (esquerdaLigada !== null) {
                    desfazerLigacao(e, esquerdaLigada);
                }
                e.pares[pendente] = id;
                delete e.marcas[pendente];
                e.pendente = null;
            } else if (esquerdaLigada !== null) {
                desfazerLigacao(e, esquerdaLigada);
            } else {
                ui.dica.textContent = 'Escolha primeiro uma frase.';
                return;
            }
        }

        e.mostrarFeedback = false;
        atualizar();
    }

    function desfazerLigacao(e, esquerda) {
        delete e.pares[esquerda];
        delete e.marcas[esquerda];
        e.pendente = null;
    }

    function atualizarAssociacao() {
        var q = atual();
        var e = edicao[q.id];
        var travada = bloqueada(q);

        q.conteudo.esquerda.forEach(function (item) {
            var li = ui.itens.esq[item.id];
            var ligada = e.pares[item.id] !== undefined;
            pintarItem(li, ui.pontos.esq[item.id], ligada, e.pendente === item.id, e.marcas[item.id], travada);
        });

        q.conteudo.direita.forEach(function (item) {
            var esquerda = chaveDoValor(e.pares, item.id);
            var marca = esquerda === null ? undefined : e.marcas[esquerda];
            pintarItem(ui.itens.dir[item.id], ui.pontos.dir[item.id], esquerda !== null, false, marca, travada);
        });

        desenharLinhas();
    }

    function pintarItem(li, ponto, ligada, pendente, marca, travada) {
        li.classList.toggle('ligado', ligada);
        li.classList.toggle('pendente', pendente);
        li.classList.toggle('ok', ligada && marca === true);
        li.classList.toggle('erro', ligada && marca === false);
        li.classList.toggle('travado', travada);
        li.querySelector('.assoc-marca').textContent = ligada && marca === true ? '✔' : (ligada && marca === false ? '✖' : '');
        ponto.disabled = travada;
        ponto.setAttribute('aria-pressed', ligada || pendente ? 'true' : 'false');
    }

    function centroDoPonto(ponto, caixaBase) {
        var r = ponto.getBoundingClientRect();
        return {x: r.left + r.width / 2 - caixaBase.left, y: r.top + r.height / 2 - caixaBase.top};
    }

    function caminhoCurvo(a, b) {
        var folga = Math.max(Math.abs(b.x - a.x) / 2, 20);
        return 'M ' + a.x + ' ' + a.y + ' C ' + (a.x + folga) + ' ' + a.y + ', ' + (b.x - folga) + ' ' + b.y + ', ' + b.x + ' ' + b.y;
    }

    // Redesenha todas as linhas a partir da posição atual dos pontos
    function desenharLinhas() {
        if (!ui.svg || !ui.wrap || !ui.q || ui.q.tipo !== 'ASSOCIACAO') {
            return;
        }
        var e = edicao[ui.q.id];
        var caixa = ui.wrap.getBoundingClientRect();

        ui.svg.setAttribute('viewBox', '0 0 ' + caixa.width + ' ' + caixa.height);
        ui.svg.setAttribute('width', caixa.width);
        ui.svg.setAttribute('height', caixa.height);
        while (ui.svg.firstChild) {
            ui.svg.removeChild(ui.svg.firstChild);
        }

        Object.keys(e.pares).forEach(function (esquerda) {
            var inicio = centroDoPonto(ui.pontos.esq[esquerda], caixa);
            var fim = centroDoPonto(ui.pontos.dir[e.pares[esquerda]], caixa);
            var marca = e.marcas[esquerda];
            var d = caminhoCurvo(inicio, fim);

            ui.svg.appendChild(svgEl('path', {
                d: d, class: 'assoc-linha' + (marca === true ? ' ok' : (marca === false ? ' erro' : ''))
            }));

            // Área larga e invisível: clicar na linha desfaz a ligação
            var area = svgEl('path', {d: d, class: 'assoc-clique'});
            area.addEventListener('click', function () {
                clicarPonto('esq', esquerda);
            });
            ui.svg.appendChild(area);
        });

        // Linha provisória enquanto o aluno escolhe a palavra
        if (e.pendente && ponteiro && ui.pontos.esq[e.pendente]) {
            var origem = centroDoPonto(ui.pontos.esq[e.pendente], caixa);
            ui.svg.appendChild(svgEl('path', {d: caminhoCurvo(origem, ponteiro), class: 'assoc-linha provisoria'}));
        }
    }

    // ---------- Formato 2: preencha a frase ----------

    function lacunasDe(q) {
        var numeros = [];
        var regex = /\{(\d+)\}/g;
        var achado;
        while ((achado = regex.exec(q.conteudo.frase)) !== null) {
            numeros.push(achado[1]);
        }
        return numeros;
    }

    function montarPreenchimento(q) {
        var frase = el('p', {class: 'preench-frase'});
        var partes = q.conteudo.frase.split(/\{(\d+)\}/);

        ui.lacunas = {};
        ui.opcoes = {};

        partes.forEach(function (parte, i) {
            if (i % 2 === 0) {
                frase.appendChild(document.createTextNode(parte));
            } else {
                var botao = el('button', {type: 'button', class: 'lacuna', onclick: function () {
                    clicarLacuna(parte);
                }});
                ui.lacunas[parte] = botao;
                frase.appendChild(botao);
            }
        });

        var grupo = el('div', {class: 'preench-opcoes', role: 'group', 'aria-label': 'Verbos disponíveis'});
        q.conteudo.opcoes.forEach(function (opcao) {
            var botao = el('button', {type: 'button', class: 'opcao-verbo', text: opcao.texto, onclick: function () {
                clicarOpcao(opcao.id);
            }});
            ui.opcoes[opcao.id] = botao;
            grupo.appendChild(botao);
        });

        ui.area.appendChild(frase);
        ui.area.appendChild(el('p', {class: 'preench-legenda', text: 'Verbos para completar a frase:'}));
        ui.area.appendChild(grupo);
    }

    function primeiraLacunaVazia(q, e) {
        var numeros = lacunasDe(q);
        for (var i = 0; i < numeros.length; i++) {
            if (e.lacunas[numeros[i]] === undefined) {
                return numeros[i];
            }
        }
        return null;
    }

    function clicarLacuna(numero) {
        var q = atual();
        if (bloqueada(q)) {
            return;
        }
        var e = edicao[q.id];

        if (e.lacunas[numero] !== undefined) {
            // Clicar em uma lacuna preenchida devolve o verbo e deixa a lacuna pronta para uma nova escolha
            delete e.lacunas[numero];
            delete e.marcas[numero];
            e.ativa = numero;
        } else {
            e.ativa = e.ativa === numero ? null : numero;
        }
        e.mostrarFeedback = false;
        atualizar();
    }

    function clicarOpcao(id) {
        var q = atual();
        if (bloqueada(q)) {
            return;
        }
        var e = edicao[q.id];
        var lacunaDoVerbo = chaveDoValor(e.lacunas, id);

        if (lacunaDoVerbo !== null) {
            // Clicar em um verbo já usado o devolve para a lista
            delete e.lacunas[lacunaDoVerbo];
            delete e.marcas[lacunaDoVerbo];
            e.ativa = lacunaDoVerbo;
        } else {
            var destino = e.ativa !== null && e.lacunas[e.ativa] === undefined ? e.ativa : primeiraLacunaVazia(q, e);
            if (destino === null) {
                ui.dica.textContent = 'Todas as lacunas estão preenchidas. Toque em uma lacuna para trocar o verbo.';
                return;
            }
            e.lacunas[destino] = id;
            delete e.marcas[destino];
            e.ativa = null;
        }
        e.mostrarFeedback = false;
        atualizar();
    }

    function atualizarPreenchimento() {
        var q = atual();
        var e = edicao[q.id];
        var travada = bloqueada(q);
        var alvo = e.ativa !== null && e.lacunas[e.ativa] === undefined ? e.ativa : null;

        lacunasDe(q).forEach(function (numero) {
            var botao = ui.lacunas[numero];
            var opcaoId = e.lacunas[numero];
            var marca = e.marcas[numero];
            var texto = opcaoId === undefined ? '______' : textoDe(q.conteudo.opcoes, opcaoId);

            if (opcaoId !== undefined && marca === true) {
                texto += ' ✔';
            } else if (opcaoId !== undefined && marca === false) {
                texto += ' ✖';
            }

            botao.textContent = texto;
            botao.classList.toggle('preenchida', opcaoId !== undefined);
            botao.classList.toggle('ativa', alvo === numero);
            botao.classList.toggle('ok', opcaoId !== undefined && marca === true);
            botao.classList.toggle('erro', opcaoId !== undefined && marca === false);
            botao.disabled = travada;
            botao.setAttribute('aria-label', 'Lacuna ' + numero + ': ' + (opcaoId === undefined ? 'vazia' : textoDe(q.conteudo.opcoes, opcaoId)));
        });

        q.conteudo.opcoes.forEach(function (opcao) {
            var usada = chaveDoValor(e.lacunas, opcao.id) !== null;
            var botao = ui.opcoes[opcao.id];
            botao.classList.toggle('usada', usada);
            botao.disabled = travada;
            botao.setAttribute('aria-pressed', usada ? 'true' : 'false');
        });
    }

    // ---------- Formato 3: múltipla escolha ----------

    function montarMultiplaEscolha(q) {
        var lista = el('div', {class: 'alternativas', role: 'group', 'aria-label': 'Alternativas'});
        ui.alternativas = {};

        q.conteudo.opcoes.forEach(function (opcao, i) {
            var botao = el('button', {
                type: 'button',
                class: 'alternativa alternativa-quiz alt-' + LETRAS[i].toLowerCase(),
                onclick: function () {
                    escolherAlternativa(opcao.id);
                }
            }, [
                el('span', {class: 'letra-alternativa', 'aria-hidden': 'true', text: LETRAS[i]}),
                el('span', {class: 'texto-alternativa', text: opcao.texto})
            ]);
            ui.alternativas[opcao.id] = botao;
            lista.appendChild(botao);
        });

        ui.area.appendChild(lista);
    }

    // Clicar só seleciona (e pode trocar). A tentativa só é registrada em "Confirmar resposta".
    function escolherAlternativa(id) {
        var q = atual();
        if (bloqueada(q)) {
            return;
        }
        var e = edicao[q.id];
        e.opcao = id;
        e.mostrarFeedback = false;
        atualizar();
    }

    function atualizarMultiplaEscolha() {
        var q = atual();
        var e = edicao[q.id];
        var travada = bloqueada(q);
        var gabarito = q.estado.gabarito;

        q.conteudo.opcoes.forEach(function (opcao) {
            var botao = ui.alternativas[opcao.id];
            var escolhida = e.opcao === opcao.id;
            var correta = q.estado.resolvida && gabarito && gabarito.correta === opcao.id;
            var errada = q.estado.resolvida && escolhida && !q.estado.acertou;

            botao.classList.toggle('escolhida', escolhida);
            botao.classList.toggle('correta', !!correta);
            botao.classList.toggle('incorreta', errada);
            botao.disabled = travada;
            botao.setAttribute('aria-pressed', escolhida ? 'true' : 'false');
        });
    }

    // ---------- Ler a questão em voz alta (voz do navegador, como na avaliação inicial) ----------

    function ouvir(q) {
        if (!('speechSynthesis' in window)) {
            return;
        }
        if (window.speechSynthesis.speaking) {
            pararAudio(); // clicar de novo enquanto fala interrompe a leitura
            return;
        }
        var fala = [];
        if (q.textoApoio) {
            fala.push(q.textoApoio);
        }
        fala.push(q.enunciado);

        if (q.tipo === 'MULTIPLA_ESCOLHA') {
            q.conteudo.opcoes.forEach(function (opcao, i) {
                fala.push('Alternativa ' + LETRAS[i] + '. ' + opcao.texto);
            });
        } else if (q.tipo === 'ASSOCIACAO') {
            q.conteudo.esquerda.forEach(function (item) {
                fala.push(item.texto);
            });
            fala.push('Palavras: ' + q.conteudo.direita.map(function (item) {
                return item.texto;
            }).join(', '));
        } else {
            fala.push(q.conteudo.frase.replace(/\{\d+\}/g, 'lacuna'));
            fala.push('Verbos: ' + q.conteudo.opcoes.map(function (opcao) {
                return opcao.texto;
            }).join(', '));
        }

        var voz = new SpeechSynthesisUtterance(fala.join('. '));
        voz.lang = 'pt-BR';
        voz.rate = 0.85;
        window.speechSynthesis.speak(voz);
    }

    window.addEventListener('beforeunload', pararAudio);
    window.addEventListener('resize', desenharLinhas);
    if (document.fonts && document.fonts.ready) {
        document.fonts.ready.then(desenharLinhas);
    }

    // Ao entrar na fase: retoma a rodada em andamento ou, se a anterior já terminou, começa uma nova na questão 1
    carregar(true);
})();
