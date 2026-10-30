extends Node2D

const W := 1280.0
const H := 720.0
const GOAL := 5800.0
const CHARS := [
 {"id":"turista","name":"Turista","skill":"Modo furtivo","task":"Inicial","dist":0.0,"pts":0,"speed":1.02,"hp":100,"power":"stealth","shirt":Color("#13a6ba"),"accent":Color("#f0d38b")},
 {"id":"presidente","name":"Presidente","skill":"Rajada de espuma","task":"Inicial","dist":0.0,"pts":0,"speed":1.0,"hp":105,"power":"blast","shirt":Color("#173653"),"accent":Color("#f3cf42")},
 {"id":"motoboy","name":"Motoboy","skill":"Turbo de entrega","task":"Inicial","dist":0.0,"pts":0,"speed":1.15,"hp":95,"power":"dash","shirt":Color("#d83c34"),"accent":Color("#f5c64a")},
 {"id":"chocolate","name":"Chocolate","skill":"Armadilha doce","task":"Percorra 500 m","dist":500.0,"pts":0,"speed":1.02,"hp":110,"power":"trap","shirt":Color("#693b2b"),"accent":Color("#d69a52")},
 {"id":"padre","name":"Padre","skill":"Benção","task":"Percorra 850 m","dist":850.0,"pts":0,"speed":0.98,"hp":120,"power":"heal","shirt":Color("#232832"),"accent":Color("#f3eee3")},
 {"id":"militar","name":"Militar","skill":"Arrancada blindada","task":"Percorra 1.200 m","dist":1200.0,"pts":0,"speed":1.05,"hp":125,"power":"armor","shirt":Color("#536b3f"),"accent":Color("#d3c28b")},
 {"id":"jornalista","name":"Jornalista","skill":"Flash da imprensa","task":"Faça 900 pontos","dist":0.0,"pts":900,"speed":1.03,"hp":100,"power":"flash","shirt":Color("#17638e"),"accent":Color("#f1f5f8")},
 {"id":"gotinha","name":"Zé Gotinha","skill":"Kit de energia","task":"Percorra 1.800 m","dist":1800.0,"pts":0,"speed":1.0,"hp":115,"power":"heal","shirt":Color("#d8f5ff"),"accent":Color("#219cc7")},
 {"id":"cowboy","name":"Cowboy","skill":"Laço de confete","task":"Faça 1.600 pontos","dist":0.0,"pts":1600,"speed":1.12,"hp":100,"power":"lasso","shirt":Color("#8a542f"),"accent":Color("#efc65d")},
 {"id":"jair","name":"Jair Bolsonaro","skill":"Escopeta de confete","task":"Faça 2.400 pontos","dist":0.0,"pts":2400,"speed":1.06,"hp":110,"power":"confetti","shirt":Color("#1b583b"),"accent":Color("#f0d147")},
 {"id":"patriota","name":"Patriota do Caminhão","skill":"Buzinaço","task":"Percorra 3.000 m","dist":3000.0,"pts":0,"speed":1.1,"hp":110,"power":"horn","shirt":Color("#1c573d"),"accent":Color("#e8cf46")},
 {"id":"tiozap","name":"Tio do Zap","skill":"Corrente viral","task":"Faça 3.400 pontos","dist":0.0,"pts":3400,"speed":1.0,"hp":105,"power":"viral","shirt":Color("#435b79"),"accent":Color("#73d8a4")},
 {"id":"hipotetico","name":"Flávio Hipotético","skill":"Maleta blindada","task":"4.200 m + 3.800 pts","dist":4200.0,"pts":3800,"speed":1.28,"hp":140,"power":"briefcase","shirt":Color("#172e50"),"accent":Color("#eab83e")}
]
const START := Rect2(90, 510, 315, 76)
const HOW := Rect2(430, 510, 225, 76)
const BACK := Rect2(75, 638, 230, 58)
const PLAY := Rect2(890, 638, 300, 58)

var state := "menu"
var font: Font
var city: Texture2D
var hero: Texture2D
var logo: Texture2D
var atlas: Texture2D
var selected_id := "turista"
var chosen: Dictionary = {}
var player := Vector2(260, 610)
var move := Vector2.ZERO
var joy := false
var turbo := false
var timer := 0.0
var world := 0.0
var distance := 0.0
var score := 0
var score_part := 0.0
var hp := 100.0
var record_distance := 0.0
var record_score := 0
var invuln := 0.0
var skill_time := 0.0
var skill_cd := 0.0
var turbo_time := 0.0
var spawn_person := 1.0
var spawn_car := 1.7
var spawn_pickup := 3.0
var ending_time := 0.0
var won := false
var people: Array = []
var cars: Array = []
var pickups: Array = []
var confetti: Array = []

func _ready() -> void:
 randomize()
 font = ThemeDB.fallback_font
 city = load("res://assets/city.svg") as Texture2D
 hero = load("res://assets/flavio_hero.svg") as Texture2D
 logo = load("res://assets/icon.svg") as Texture2D
 atlas = load("res://assets/portraits.svg") as Texture2D
 _load_records()

func _process(dt: float) -> void:
 timer += dt
 if state == "game":
  _keyboard()
  _update_game(dt)
 elif state == "ending":
  ending_time += dt
  world += dt * 150.0
  if ending_time > 5.5:
   won = true
   state = "result"
   _save_records()
 queue_redraw()

func _draw() -> void:
 _draw_city()
 match state:
  "menu": _menu()
  "select": _select()
  "how": _how()
  "game": _game()
  "pause":
   _game()
   _pause()
  "ending": _ending()
  "result": _result()

func _draw_city() -> void:
 if city:
  draw_texture_rect(city, Rect2(0, 0, W, H), false)
 else:
  draw_rect(Rect2(0,0,W,H), Color("#79b6d4"), true)
  draw_rect(Rect2(0,540,W,180), Color("#424d59"), true)
 draw_rect(Rect2(0,0,W,H), Color(0.02,0.05,0.09,0.2), true)
 var off := fposmod(world, 190.0)
 for i in range(9):
  draw_rect(Rect2(i*190.0-off, 650, 90, 6), Color("#f0e5bd"), true)

func _menu() -> void:
 _panel(Rect2(34,38,1212,640), Color(0.025,0.07,0.13,0.84))
 if logo:
  draw_texture_rect(logo, Rect2(83,90,176,176), false)
 _txt("FUGA DA", Vector2(288,168), 64, Color.WHITE)
 _txt("FRONTEIRA", Vector2(286,249), 72, Color("#ffd05a"))
 _txt("FLÁVIO EM MAIS UM DISFARCE", Vector2(92,322), 18, Color("#8edcff"))
 _txt("UMA CORRIDA. TREZE VISUAIS.", Vector2(90,378), 35, Color.WHITE)
 _txt("UMA FRONTEIRA NO CAMINHO.", Vector2(90,421), 35, Color.WHITE)
 _txt("Atravesse a cidade, escape das perseguições e encontre a passagem para a Argentina.", Vector2(92,480), 16, Color("#d5e4ef"))
 _txt("No final, um jato com Trump no comando espera na pista.", Vector2(92,503), 16, Color("#d5e4ef"))
 _button(START, "COMEÇAR A FUGA", true)
 _button(HOW, "COMO JOGAR", false)
 _panel(Rect2(745,105,445,440), Color(0.05,0.13,0.21,0.8))
 _txt("MISSÃO PRINCIPAL", Vector2(780,155), 17, Color("#ffc94c"))
 _txt("PASSAGEM PARA", Vector2(780,215), 35, Color.WHITE)
 _txt("ARGENTINA", Vector2(780,258), 39, Color.WHITE)
 _feature(Vector2(788,325), "CIDADE VIVA", "Cenário urbano e trânsito.", Color("#65c1e9"))
 _feature(Vector2(788,402), "PERSEGUIÇÃO", "PF, manifestantes e viaturas.", Color("#e7b94c"))
 _feature(Vector2(788,479), "GRANDE FINAL", "Fronteira e jato pilotado por Trump.", Color("#68d29a"))
 _txt("PARÓDIA ARCADE FICTÍCIA · TOQUE PARA JOGAR", Vector2(90,655), 14, Color("#a6c0d2"))

func _select() -> void:
 _panel(Rect2(22,22,1236,680), Color(0.025,0.065,0.12,0.92))
 _txt("ESCOLHA SEU DISFARCE", Vector2(54,72), 33, Color.WHITE)
 _txt("10 disfarces exigem missões. Flávio Hipotético é o mais forte e o último desbloqueio.", Vector2(56,106), 17, Color("#b9d0e1"))
 var free_count := 0
 for i in range(CHARS.size()):
  var c: Dictionary = CHARS[i]
  var r := Rect2(32+(i%5)*245, 132+int(i/5)*164, 235, 151)
  _card(c, i, r)
  if _unlocked(c):
   free_count += 1
 _button(BACK, "VOLTAR", false)
 _button(PLAY, "PARTIR PRA FUGA", true)
 _txt("LIBERADOS %d/13  ·  RECORDE %d PTS  ·  DISTÂNCIA %d M" % [free_count, record_score, int(record_distance)], Vector2(330,675), 14, Color("#e4d095"))

func _card(c: Dictionary, index: int, r: Rect2) -> void:
 var open := _unlocked(c)
 var chosen_card: bool = c.id == selected_id
 draw_rect(r, Color("#203b55") if open else Color("#111f30"), true)
 draw_rect(r, Color("#f3c64a") if chosen_card else Color("#527b94"), false, 3.0 if chosen_card else 1.5)
 if c.id == "hipotetico" and hero:
  draw_texture_rect(hero, Rect2(r.position.x+8,r.position.y+7,99,136), false)
 elif atlas:
  draw_texture_rect_region(atlas, Rect2(r.position.x+8,r.position.y+10,99,130), Rect2(float(index%5)*320.0,float(int(index/5))*380.0,320,380))
 var tx := r.position.x+116
 if c.id == "patriota":
  _txt("Patriota do", Vector2(tx,r.position.y+35), 15, Color.WHITE)
  _txt("Caminhão", Vector2(tx,r.position.y+53), 15, Color.WHITE)
 elif c.id == "hipotetico":
  _txt("Flávio", Vector2(tx,r.position.y+35), 16, Color.WHITE)
  _txt("Hipotético", Vector2(tx,r.position.y+53), 16, Color.WHITE)
 else:
  _txt(String(c.name), Vector2(tx,r.position.y+42), 15 if String(c.name).length()>15 else 18, Color.WHITE if open else Color("#b3c1cc"))
 _txt(String(c.skill), Vector2(tx,r.position.y+78), 12, Color("#83d6f0"))
 if open:
  _txt("LIBERADO", Vector2(tx,r.position.y+121), 13, Color("#7ce0a8"))
 else:
  _txt("MISSÃO: "+String(c.task), Vector2(tx,r.position.y+119), 11, Color("#e4d4b5"))
  draw_rect(r, Color(0.02,0.035,0.06,0.24), true)
  _txt("BLOQUEADO", Vector2(r.position.x+13,r.position.y+143), 10, Color("#f0ce70"))

func _how() -> void:
 _panel(Rect2(64,54,1152,610), Color(0.02,0.06,0.11,0.92))
 _txt("COMO JOGAR", Vector2(105,115), 38, Color.WHITE)
 _txt("CONTROLES", Vector2(108,185), 20, Color("#ffcc50"))
 _txt("• Analógico esquerdo: mova o personagem em 360 graus.", Vector2(108,227), 19, Color("#e4edf4"))
 _txt("• PODER: ativa a habilidade especial do disfarce escolhido.", Vector2(108,258), 19, Color("#e4edf4"))
 _txt("• TURBO: acelera por alguns segundos; use para escapar de viaturas.", Vector2(108,289), 19, Color("#e4edf4"))
 _txt("• Computador: WASD/setas, Espaço para poder e Shift para turbo.", Vector2(108,320), 19, Color("#e4edf4"))
 _txt("OBJETIVO", Vector2(108,390), 20, Color("#ffcc50"))
 _txt("Desvie das pessoas e dos carros que entram pela direita da tela.", Vector2(108,430), 18, Color("#e4edf4"))
 _txt("Os manifestantes carregam uma placa escrita LULA.", Vector2(108,458), 18, Color("#e4edf4"))
 _txt("Colete itens, complete missões e desbloqueie os 13 disfarces.", Vector2(108,486), 18, Color("#e4edf4"))
 _txt("A escopeta do Jair é cenográfica: dispara apenas confete.", Vector2(108,514), 18, Color("#e4edf4"))
 _txt("Chegue à fronteira e embarque no jato pilotado por Trump.", Vector2(108,542), 18, Color("#e4edf4"))
 _button(Rect2(92,590,240,58), "ENTENDI", true)

func _game() -> void:
 for p in pickups:
  _pickup(p)
 for c in cars:
  _car(c)
 for p in people:
  _person(p)
 for s in confetti:
  draw_circle(s.pos, 7.0, s.color)
 _player()
 _hud()

func _player() -> void:
 if selected_id == "hipotetico" and hero:
  _ellipse(player+Vector2(0,-2), Vector2(57,13), Color(0.02,0.04,0.06,0.4))
  draw_texture_rect(hero, Rect2(player.x-82,player.y-205,164,205), false)
 else:
  _actor(player, selected_id, timer*10.0, 1.0)
 if skill_time > 0:
  draw_arc(player+Vector2(0,-58), 66, 0, TAU, 64, Color("#83d8e8"), 4.0, true)

func _actor(p: Vector2, id: String, phase: float, scale_v: float) -> void:
 var ch := _char(id)
 var shirt: Color = ch.shirt if not ch.is_empty() else Color("#31556b")
 var accent: Color = ch.accent if not ch.is_empty() else Color("#f0cf51")
 var skin := Color("#d8a17d")
 var hair := Color("#332822")
 if id == "jair": hair = Color("#c7c1b4")
 if id == "tiozap": hair = Color("#dedbd3")
 if id == "gotinha": skin = Color("#f4fbff")
 _ellipse(p+Vector2(0,-1), Vector2(31,9)*scale_v, Color(0.02,0.04,0.06,0.35))
 var a := Vector2(-10+sin(phase)*14,18+absf(cos(phase))*13)*scale_v
 var b := Vector2(10-sin(phase)*14,18+absf(sin(phase))*13)*scale_v
 draw_line(p+Vector2(-8,-40)*scale_v,p+a,Color("#1d2430"),16*scale_v,true)
 draw_line(p+Vector2(-8,-40)*scale_v,p+a,shirt.darkened(0.1),10*scale_v,true)
 draw_line(p+Vector2(8,-40)*scale_v,p+b,Color("#1d2430"),16*scale_v,true)
 draw_line(p+Vector2(8,-40)*scale_v,p+b,shirt.darkened(0.1),10*scale_v,true)
 draw_line(p+a,p+a+Vector2(17,3)*scale_v,Color("#182330"),11*scale_v,true)
 draw_line(p+b,p+b+Vector2(15,3)*scale_v,Color("#182330"),11*scale_v,true)
 var arm_a := Vector2(-37,-57+sin(phase)*15)*scale_v
 var arm_b := Vector2(37,-57-sin(phase)*15)*scale_v
 draw_line(p+Vector2(-18,-70)*scale_v,p+arm_a,Color("#2b2530"),16*scale_v,true)
 draw_line(p+Vector2(-18,-70)*scale_v,p+arm_a,shirt,10*scale_v,true)
 draw_line(p+Vector2(18,-70)*scale_v,p+arm_b,Color("#2b2530"),16*scale_v,true)
 draw_line(p+Vector2(18,-70)*scale_v,p+arm_b,shirt,10*scale_v,true)
 draw_circle(p+arm_a,9*scale_v,skin)
 draw_circle(p+arm_b,9*scale_v,skin)
 draw_colored_polygon(PackedVector2Array([p+Vector2(-23,-92)*scale_v,p+Vector2(23,-92)*scale_v,p+Vector2(29,-42)*scale_v,p+Vector2(-27,-42)*scale_v]),shirt)
 draw_circle(p+Vector2(0,-111)*scale_v,23*scale_v,skin)
 draw_arc(p+Vector2(0,-111)*scale_v,23*scale_v,PI,TAU,24,hair,5*scale_v,true)
 draw_circle(p+Vector2(-8,-112)*scale_v,2.8*scale_v,Color("#1e2228"))
 draw_circle(p+Vector2(8,-112)*scale_v,2.8*scale_v,Color("#1e2228"))
 draw_line(p+Vector2(-7,-99)*scale_v,p+Vector2(7,-99)*scale_v,Color("#844e43"),2.3*scale_v,true)
 if id == "turista":
  draw_rect(Rect2(p+Vector2(-19,-119)*scale_v,Vector2(18,10)*scale_v),Color("#132e3b"),true)
  draw_rect(Rect2(p+Vector2(2,-119)*scale_v,Vector2(18,10)*scale_v),Color("#132e3b"),true)
 elif id == "motoboy":
  draw_arc(p+Vector2(0,-116)*scale_v,24*scale_v,PI,TAU,20,Color("#d33832"),9*scale_v,true)
 elif id == "padre":
  draw_rect(Rect2(p+Vector2(-7,-91)*scale_v,Vector2(14,9)*scale_v),Color("#f8f3e9"),true)
 elif id == "cowboy":
  draw_rect(Rect2(p+Vector2(-31,-142)*scale_v,Vector2(62,8)*scale_v),Color("#8a552f"),true)
  draw_rect(Rect2(p+Vector2(-18,-160)*scale_v,Vector2(36,20)*scale_v),Color("#8a552f"),true)
 elif id == "jair":
  draw_rect(Rect2(p+Vector2(27,-87)*scale_v,Vector2(49,9)*scale_v),Color("#3a4b58"),true)
  draw_circle(p+Vector2(73,-81)*scale_v,7*scale_v,Color("#f2d34e"))
 elif id == "tiozap":
  draw_rect(Rect2(p+Vector2(24,-82)*scale_v,Vector2(20,34)*scale_v),Color("#283643"),true)
  draw_rect(Rect2(p+Vector2(27,-78)*scale_v,Vector2(14,24)*scale_v),Color("#80d8a7"),true)
 elif id == "hipotetico":
  draw_line(p+Vector2(-6,-88)*scale_v,p+Vector2(0,-47)*scale_v,accent,7*scale_v,true)

func _person(p: Dictionary) -> void:
 var pos := Vector2(p.x,p.y)
 if p.kind == "supporter":
  _actor(pos,"patriota",p.phase,0.86)
  draw_rect(Rect2(pos.x-52,pos.y-167,112,49),Color("#fff8e9"),true)
  draw_rect(Rect2(pos.x-52,pos.y-167,112,49),Color("#8b3340"),false,3.0)
  _txt("LULA",Vector2(pos.x-43,pos.y-134),25,Color("#c72c3a"))
 else:
  _actor(pos,"militar",p.phase,0.86)
  draw_rect(Rect2(pos.x-34,pos.y-160,67,27),Color("#172a3b"),true)
  _txt("PF",Vector2(pos.x-24,pos.y-140),17,Color.WHITE)

func _car(c: Dictionary) -> void:
 var x: float = c.x
 var y: float = c.y
 var pf: bool = c.kind == "pf"
 var paint := Color("#f3f2e9") if pf else Color("#d6a83b")
 draw_ellipse(Vector2(x+88,y+32),Vector2(95,13),Color(0.02,0.035,0.05,0.35))
 draw_rect(Rect2(x,y-53,182,70),paint,true)
 draw_rect(Rect2(x,y-53,182,70),Color("#172537"),false,5.0)
 draw_colored_polygon(PackedVector2Array([Vector2(x+28,y-53),Vector2(x+54,y-82),Vector2(x+133,y-82),Vector2(x+158,y-53)]),paint)
 draw_rect(Rect2(x+61,y-75,29,20),Color("#83c9e4"),true)
 draw_rect(Rect2(x+98,y-75,33,20),Color("#83c9e4"),true)
 draw_circle(Vector2(x+43,y+14),19,Color("#202935"))
 draw_circle(Vector2(x+143,y+14),19,Color("#202935"))
 draw_circle(Vector2(x+43,y+14),8,Color("#b5c4cd"))
 draw_circle(Vector2(x+143,y+14),8,Color("#b5c4cd"))
 if pf:
  draw_rect(Rect2(x+65,y-47,65,14),Color("#172c47"),true)
  _txt("POLÍCIA",Vector2(x+72,y-35),10,Color.WHITE)
  draw_rect(Rect2(x+80,y-91,30,8),Color("#202e3e"),true)
  draw_rect(Rect2(x+81,y-90,12,6),Color("#d84242"),true)
  draw_rect(Rect2(x+96,y-90,12,6),Color("#3c8bce"),true)

func _pickup(p: Dictionary) -> void:
 var pos: Vector2 = p.pos
 if p.kind == "money":
  draw_rect(Rect2(pos.x-17,pos.y-12,34,24),Color("#e6c24d"),true)
  draw_rect(Rect2(pos.x-17,pos.y-12,34,24),Color("#8a6826"),false,2.0)
  _txt("$",Vector2(pos.x-6,pos.y+7),18,Color("#4a3716"))
 else:
  draw_rect(Rect2(pos.x-18,pos.y-18,36,36),Color("#eaf5f8"),true)
  draw_rect(Rect2(pos.x-18,pos.y-18,36,36),Color("#2b97be"),false,3.0)
  draw_rect(Rect2(pos.x-4,pos.y-12,8,24),Color("#2b97be"),true)
  draw_rect(Rect2(pos.x-12,pos.y-4,24,8),Color("#2b97be"),true)

func _hud() -> void:
 draw_rect(Rect2(0,0,W,90),Color(0.015,0.045,0.08,0.84),true)
 _txt("ENERGIA",Vector2(30,28),13,Color("#a8c6d9"))
 _txt("%d%%" % int(hp),Vector2(30,60),25,Color.WHITE)
 draw_rect(Rect2(118,31,180,17),Color("#31485a"),true)
 draw_rect(Rect2(118,31,180*clampf(hp/float(chosen.hp),0.0,1.0),17),Color("#e6b94d") if hp>35 else Color("#e45a58"),true)
 _txt("ATÉ A FRONTEIRA",Vector2(520,28),13,Color("#a8c6d9"))
 _txt("%s KM" % _km(maxf(0.0,GOAL-distance)),Vector2(520,62),27,Color.WHITE)
 draw_rect(Rect2(737,34,240,14),Color("#31485a"),true)
 draw_rect(Rect2(737,34,240*clampf(distance/GOAL,0.0,1.0),14),Color("#39b8e7"),true)
 _txt("PONTOS",Vector2(1012,28),13,Color("#a8c6d9"))
 _txt(str(score),Vector2(1012,62),27,Color.WHITE)
 _txt(String(chosen.name).to_upper(),Vector2(1110,30),11,Color("#ffce59"))
 _button(Rect2(1190,16,64,54),"Ⅱ",false,24)
 _txt("PODER "+("PRONTO" if skill_cd<=0 else "%.1fs" % skill_cd),Vector2(1000,114),13,Color("#ffdc83"))
 draw_circle(Vector2(116,604),75,Color(0.06,0.15,0.22,0.55))
 draw_arc(Vector2(116,604),75,0,TAU,64,Color("#d8efff"),3.0,true)
 draw_circle(Vector2(116,604)+move*33,30,Color("#7bb8dc"))
 draw_arc(Vector2(116,604)+move*33,30,0,TAU,40,Color("#d8efff"),3.0,true)
 _button(Rect2(1060,548,145,78),"PODER",true,19)
 _button(Rect2(1093,639,112,56),"TURBO",false,16)

func _ending() -> void:
 draw_rect(Rect2(0,0,W,H),Color(0.02,0.07,0.12,0.33),true)
 draw_rect(Rect2(0,440,W,280),Color("#414b57"),true)
 for i in range(8):
  draw_rect(Rect2(i*180+35,570,100,7),Color("#e4d59e"),true)
 draw_rect(Rect2(110,300,375,110),Color("#0b6b48"),true)
 draw_rect(Rect2(110,300,375,110),Color("#f7e8bb"),false,5.0)
 _txt("ARGENTINA",Vector2(150,350),46,Color.WHITE)
 _txt("FRONTEIRA LIBERADA",Vector2(155,386),19,Color("#ffd451"))
 _plane(Vector2(lerpf(840.0,580.0,minf(1.0,ending_time/5.0)),405))
 draw_rect(Rect2(58,55,1164,115),Color(0.02,0.06,0.1,0.84),true)
 _txt("VOCÊ CHEGOU À FRONTEIRA!",Vector2(90,105),38,Color.WHITE)
 _txt("O jato está pronto. Trump assumiu o cockpit.",Vector2(92,143),21,Color("#ffd66b"))

func _plane(c: Vector2) -> void:
 draw_colored_polygon(PackedVector2Array([c+Vector2(-260,0),c+Vector2(-90,-27),c+Vector2(115,-14),c+Vector2(270,10),c+Vector2(120,34),c+Vector2(-90,28)]),Color("#edf3f4"))
 draw_colored_polygon(PackedVector2Array([c+Vector2(-28,-8),c+Vector2(72,-130),c+Vector2(126,-126),c+Vector2(72,-3)]),Color("#c9dce8"))
 draw_colored_polygon(PackedVector2Array([c+Vector2(-90,4),c+Vector2(-177,-75),c+Vector2(-141,-80),c+Vector2(-35,-5)]),Color("#d5e2eb"))
 draw_rect(Rect2(c.x-5,c.y-19,94,20),Color("#70b5d7"),true)
 draw_circle(c+Vector2(39,-9),16,Color("#e7b38b"))
 draw_arc(c+Vector2(39,-13),16,PI,TAU,20,Color("#e7c452"),8.0,true)
 draw_rect(Rect2(c.x+27,c.y+2,25,13),Color("#183b60"),true)

func _pause() -> void:
 draw_rect(Rect2(0,0,W,H),Color(0.01,0.025,0.05,0.74),true)
 _panel(Rect2(360,210,560,300),Color("#10263c"))
 _txt("PAUSA",Vector2(550,290),48,Color.WHITE)
 _txt("A perseguição também precisa respirar.",Vector2(444,345),19,Color("#c9d9e4"))
 _button(Rect2(420,395,205,65),"CONTINUAR",true)
 _button(Rect2(655,395,205,65),"SAIR",false)

func _result() -> void:
 draw_rect(Rect2(0,0,W,H),Color(0.02,0.06,0.11,0.72),true)
 _panel(Rect2(240,122,800,488),Color("#10283e"))
 if won:
  _txt("FUGA CONCLUÍDA!",Vector2(390,222),46,Color("#79e1a8"))
  _txt("O jato de Trump decolou. A fronteira ficou para trás.",Vector2(330,278),20,Color.WHITE)
 else:
  _txt("A PERSEGUIÇÃO ALCANÇOU VOCÊ",Vector2(300,222),38,Color("#ffcf65"))
  _txt("Tente outro disfarce e aproveite as habilidades especiais.",Vector2(320,278),19,Color.WHITE)
 _txt("DISTÂNCIA: %d M   PONTOS: %d" % [int(distance),score],Vector2(385,352),25,Color.WHITE)
 _txt("RECORDE: %d PTS   MELHOR DISTÂNCIA: %d M" % [record_score,int(record_distance)],Vector2(385,390),17,Color("#ffd36c"))
 _button(Rect2(330,455,285,70),"NOVO DISFARCE",true)
 _button(Rect2(650,455,285,70),"MENU",false)

func _feature(p: Vector2, title: String, desc: String, col: Color) -> void:
 draw_rect(Rect2(p.x-4,p.y-27,7,49),col,true)
 _txt(title,p+Vector2(20,-7),17,Color.WHITE)
 _txt(desc,p+Vector2(20,20),13,Color("#c8d9e7"))

func _panel(r: Rect2, col: Color) -> void:
 draw_rect(r,col,true)
 draw_rect(r,Color("#9bd1ed"),false,2.0)

func _button(r: Rect2, title: String, primary: bool, size: int = 19) -> void:
 var fill := Color("#f2bd43") if primary else Color("#244866")
 var edge := Color("#ffe7a0") if primary else Color("#83c6e3")
 draw_rect(Rect2(r.position.x,r.position.y+5,r.size.x,r.size.y),Color(0.015,0.035,0.055,0.45),true)
 draw_rect(r,fill,true)
 draw_rect(r,edge,false,2.0)
 _txt(title,r.position+Vector2(r.size.x/2,r.size.y/2+size*0.34),size,Color("#182437") if primary else Color.WHITE,HORIZONTAL_ALIGNMENT_CENTER)

func _txt(s: String, pos: Vector2, size: int, col: Color, align: int = HORIZONTAL_ALIGNMENT_LEFT) -> void:
 draw_string(font,pos,s,align,-1,size,col)

func _ellipse(c: Vector2, rad: Vector2, col: Color) -> void:
 var pts := PackedVector2Array()
 for i in range(32):
  var a := TAU*float(i)/32.0
  pts.append(c+Vector2(cos(a)*rad.x,sin(a)*rad.y))
 draw_colored_polygon(pts,col)

func _update_game(dt: float) -> void:
 world += dt*380.0
 var speed := 365.0+minf(115.0,distance/55.0)
 var mult: float = chosen.speed
 if turbo:
  turbo_time = maxf(turbo_time,1.8)
 if turbo_time>0:
  turbo_time = maxf(0.0,turbo_time-dt)
  speed *= 1.45
 distance += dt*20.0*mult
 score_part += dt*11.0*mult
 var pts := int(score_part)
 score += pts
 score_part -= float(pts)
 player += move*dt*340.0*mult
 player.x = clampf(player.x,150.0,680.0)
 player.y = clampf(player.y,520.0,680.0)
 invuln = maxf(0.0,invuln-dt)
 skill_time = maxf(0.0,skill_time-dt)
 skill_cd = maxf(0.0,skill_cd-dt)

 spawn_person -= dt
 if spawn_person<=0:
  people.append({"x":1390.0+randf_range(0,170),"y":[550.0,610.0,672.0][randi_range(0,2)],"kind":"supporter" if randi_range(0,100)<58 else "pf","speed":randf_range(180,250),"phase":randf()*TAU})
  spawn_person = randf_range(1.15,2.1)
 spawn_car -= dt
 if spawn_car<=0:
  cars.append({"x":1430.0+randf_range(0,190),"y":[566.0,635.0,694.0][randi_range(0,2)],"kind":"pf" if randi_range(0,100)<43 else "traffic","speed":randf_range(245,335)})
  spawn_car = randf_range(2.5,4.0)
 spawn_pickup -= dt
 if spawn_pickup<=0:
  pickups.append({"pos":Vector2(1370+randf_range(0,180),[550.0,615.0,675.0][randi_range(0,2)]),"kind":"money" if randf()<0.72 else "health"})
  spawn_pickup = randf_range(3.4,5.4)

 for i in range(people.size()-1,-1,-1):
  var p: Dictionary = people[i]
  p.x -= (speed+float(p.speed))*dt
  p.phase += dt*9.0
  if p.x < -180:
   people.remove_at(i)
   continue
  if Vector2(p.x,p.y-48).distance_to(player+Vector2(0,-55))<47 and invuln<=0 and skill_time<=0:
   _hit(15.0)
   people.remove_at(i)
  else:
   people[i] = p
 for i in range(cars.size()-1,-1,-1):
  var c: Dictionary = cars[i]
  c.x -= (speed+float(c.speed))*dt
  if c.x < -240:
   cars.remove_at(i)
   continue
  if absf(c.y-20-player.y)<76 and absf(c.x+90-player.x)<94 and invuln<=0 and skill_time<=0:
   _hit(24.0)
   cars.remove_at(i)
  else:
   cars[i] = c
 for i in range(pickups.size()-1,-1,-1):
  var p: Dictionary = pickups[i]
  p.pos.x -= speed*dt
  if p.pos.x < -40:
   pickups.remove_at(i)
  elif p.pos.distance_to(player+Vector2(0,-35))<50:
   if p.kind=="money":
    score += 150
   else:
    hp = minf(float(chosen.hp),hp+22.0)
   pickups.remove_at(i)
  else:
   pickups[i] = p
 for i in range(confetti.size()-1,-1,-1):
  var s: Dictionary = confetti[i]
  s.pos += s.vel*dt
  s.life -= dt
  if s.life<=0:
   confetti.remove_at(i)
  else:
   confetti[i] = s
 if hp<=0:
  won = false
  state = "result"
  _save_records()
 elif distance>=GOAL:
  state = "ending"
  ending_time = 0.0
  _save_records()

func _hit(amount: float) -> void:
 hp = maxf(0.0,hp-amount)
 invuln = 1.25

func _power() -> void:
 if skill_cd>0 or chosen.is_empty():
  return
 skill_cd = 13.0
 match String(chosen.power):
  "heal":
   hp = minf(float(chosen.hp),hp+42)
   skill_time = 2.0
  "dash":
   turbo_time = 3.0
   skill_time = 1.2
  "stealth":
   skill_time = 5.5
  "armor","briefcase":
   skill_time = 6.0 if chosen.power=="briefcase" else 4.5
   score += 125
  _:
   skill_time = 2.2
   score += 80
   for i in range(7):
    confetti.append({"pos":player+Vector2(55,-74),"vel":Vector2(randf_range(430,690),randf_range(-100,100)),"life":1.0,"color":[Color("#f2cf4a"),Color("#68c6ed"),Color("#72d7a1"),Color("#f17d7d")][i%4]})
   people.clear()
   if chosen.power=="confetti":
    cars.clear()

func _start() -> void:
 chosen = _char(selected_id)
 if chosen.is_empty() or not _unlocked(chosen):
  selected_id = "turista"
  chosen = _char(selected_id)
 hp = float(chosen.hp)
 player = Vector2(260,610)
 move = Vector2.ZERO
 joy = false
 turbo = false
 turbo_time = 0
 skill_time = 0
 skill_cd = 0
 invuln = 0
 distance = 0
 score = 0
 score_part = 0
 world = 0
 spawn_person = 0.9
 spawn_car = 1.7
 spawn_pickup = 2.9
 people.clear()
 cars.clear()
 pickups.clear()
 confetti.clear()
 state = "game"

func _char(id: String) -> Dictionary:
 for c in CHARS:
  if c.id==id:
   return c
 return {}

func _unlocked(c: Dictionary) -> bool:
 return record_distance>=float(c.dist) and record_score>=int(c.pts)

func _save_records() -> void:
 record_distance = maxf(record_distance,distance)
 record_score = maxi(record_score,score)
 var cfg := ConfigFile.new()
 cfg.set_value("records","distance",record_distance)
 cfg.set_value("records","score",record_score)
 cfg.save("user://progress.cfg")

func _load_records() -> void:
 var cfg := ConfigFile.new()
 if cfg.load("user://progress.cfg")==OK:
  record_distance = float(cfg.get_value("records","distance",0.0))
  record_score = int(cfg.get_value("records","score",0))

func _km(m: float) -> String:
 return "%.1f" % (m/1000.0)

func _keyboard() -> void:
 var v := Vector2.ZERO
 if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): v.x -= 1
 if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): v.x += 1
 if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): v.y -= 1
 if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): v.y += 1
 if v.length()>1: v=v.normalized()
 if not joy: move=v
 turbo = Input.is_key_pressed(KEY_SHIFT)

func _down(p: Vector2) -> void:
 if state=="menu":
  if START.has_point(p): state="select"
  elif HOW.has_point(p): state="how"
 elif state=="how":
  if Rect2(92,590,240,58).has_point(p): state="menu"
 elif state=="select":
  if BACK.has_point(p): state="menu"; return
  if PLAY.has_point(p): _start(); return
  for i in range(CHARS.size()):
   var r := Rect2(32+(i%5)*245,132+int(i/5)*164,235,151)
   if r.has_point(p):
    if _unlocked(CHARS[i]): selected_id=String(CHARS[i].id)
    return
 elif state=="pause":
  if Rect2(420,395,205,65).has_point(p): state="game"
  elif Rect2(655,395,205,65).has_point(p): state="select"
 elif state=="result":
  if Rect2(330,455,285,70).has_point(p): state="select"
  elif Rect2(650,455,285,70).has_point(p): state="menu"
 elif state=="game":
  if Rect2(1190,16,64,54).has_point(p):
   state="pause"
   move=Vector2.ZERO
  elif Rect2(1040,530,180,105).has_point(p):
   _power()
  elif Rect2(1060,630,175,80).has_point(p):
   turbo=true
  elif p.x<260 and p.y>480:
   joy=true
   _move_pointer(p)

func _move_pointer(p: Vector2) -> void:
 if joy:
  move=(p-Vector2(116,604))/68.0
  if move.length()>1: move=move.normalized()

func _up() -> void:
 joy=false
 turbo=false
 move=Vector2.ZERO

func _input(e: InputEvent) -> void:
 if e is InputEventScreenTouch:
  if e.pressed: _down(e.position)
  else: _up()
 elif e is InputEventScreenDrag:
  if joy: _move_pointer(e.position)
 elif e is InputEventMouseButton and e.button_index==MOUSE_BUTTON_LEFT:
  if e.pressed: _down(e.position)
  else: _up()
 elif e is InputEventMouseMotion:
  if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and joy: _move_pointer(e.position)
 elif e is InputEventKey and e.pressed and not e.echo:
  if e.keycode==KEY_ESCAPE:
   if state=="game": state="pause"
   elif state=="pause": state="game"
   elif state in ["select","how"]: state="menu"
  elif e.keycode==KEY_SPACE and state=="game":
   _power()
