import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFFFFDF6,
      ), // I HomeScreen background rawng chiah kha
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(
          255,
          192,
          21,
          239,
        ), // I AppBar rawng chiah kha
        title: const Text(
          'P.T Hlychho Thâtih',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BIEHMIA SECTION ---
            const Text(
              'BIEHMIA',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'PT. Hlychho ta English – Mara Dictionary a taopa he marapazy ta eima phahnaikhei ngâsâ. A viapachai ta achuhaipazy ta ama phahnaikhei via heih. He Dictionary he kô 2004 liata a hmia hmô pi ta, kô 2006 pa liata Revised & Enlarged Edition ta copy 1000 pua heih ta, chatana chô chhao ta a copy he hmô awpa y khao leipa ta atahmâ he Art & Culture Department, MADC ta copy 2000 eima papua heihpa a châ. Châbu sôh kawpa nata phahnai kawpa a taotuhpa PT. Hlychho chô liata eimâ ly hmeiseih.\n\n'
              'Marapa chi nata pho thapasana a hnei ngaitapa châ ta, marapa thâtih rona châbu nata Khazohpa bie rona châbu chhao a vaw papua ha hra.\n\n'
              'Atahmâ ano cha pasana khiakhipa hneipa vâta amohôh ngâhai ta, Abeipa ta â mohôhna liata byhnâ pie sala, thlai avaw tlâh papua awpa ta hnabeiseih pi ta, eima thlachhâna a châ hra.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),

            // Sign-off (Officer Chanchin)
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Sd/- K. Pari\nArt & Culture Officer\nMara Autonomous District Council\nSiaha',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.4,
                ),
                textAlign: TextAlign.right,
              ),
            ),

            const Divider(height: 40, thickness: 1),

            // --- INTRODUCTION SECTION ---
            const Text(
              'INTRODUCTION',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tloh lei kawna chôta English – Marâh dictionary he ei vaw pachhuah-panoh hra hih. Palôh-eih la âchhih tiarâh vei. Kheihta-e eima tah bao aw! Tahmâ taihta he hawhpa hmo thabypa châbu chhao eima hnei mâh to leipa naihta, a pha khiah ta, a pha leipa chhao rai ta, heih mo-mopasatu tawh tly cha, tahpata ei vaw tao lyh-lia. Anodeikua cha Mongyuh reih nata Marâh reih cheingei chhao, ei thaina ta â vaw daih leipa ta, baotuhpa viasa nata âsaohiah awpah châbu vâ-iapa ta daihti reipi ei vaw y. Tao nawpah hro a y khao vei tawh tly cha, Biehrai dei he baotuhpa phachaipa ta ei vaw hmâh. Chavâta he châbu he na vaw reih khiala reikah ngia viapa nata ryh-rao kheina pha viapa na vaw hnei thlyu awpata ei hnabeiseih. Kâchhiena nata âthlachhiena hnei leipata, cha-hawhpa pahruana phapa cha naw pahnosa thei la, chhuh heih tita padona châta ei vaw hmâh aw.\n\n'
              'Reih he daihti rei leipa liata ânano thei ta, âsosâh via laih thei hra; Marâh reih chhochhi la mohchho hnei chyhtu ha ta, mohchho sâkha he yzie nanopa hluhpi reina châta hmâpa a châ. Pamosana châta :-',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),

            // Numbered Examples List
            const Text(
              '1.  aw = will, shall, call, grass, disapproval of mistake. Hawrawh \'h\' baipata, awh = foul, chicken, cry out, proclaim.\n\n'
              '2.  chho = South, tell, inform, somehow, co-incide, invade. Hawrawh \'h\' baipata, chhoh = cook, old and smell, cloudy, dark. Khi chhoh = protruding fore-head, beatle-browed. Keihchhoh = black panther, dark tiger, leopard. Chhobuh âchhohpa = thick bushes.\n\n'
              '3.  chao = bottom, buttock, dig, blind. Hawrawh \'h\' baipata, chaoh = ricket.\n\n'
              '4.  chai = best, most, mostly, superlative, hip, cut. Hawrawh \'h\' baipata, chaih = bite, biting cold, severe pain, weapon.\n\n'
              '5.  cha = is, that, cry. cha cha = that is, that is to say. Hawrawh \'h\' baipata, chah! chah-i! = ugh! hawrawh \'â\' luhchhôpata, châ = it is, for, yes, letter, paper, hard, solid. hawrawh \'h\' bai heihpata, châh = halt (a day), remain, stay, verse, rotation period of duty befallen on someone, anniversary or specific period, historical event being referred. châhkita = whenever. achâhphaohta = occasionally.\n\n'
              '6.  da = depress, lower, keep down. Hawrawh \'â\' luhchhôpata, dâ = wet. Hawrawh \'h\' bai heihpata, dâh = law, rule, constitution, way, method, system, procedure, formula, quiet, silent, throat, post (office), dâh-O = post office.\n\n'
              '7.  haw = (as past tense), had been, already; demand, claim, request, plea, ask, tea-leaf. hawrawh \'h\' baipata, hawh = late, delayed.\n\n'
              '8.  sa = meat, flesh, weave, sing, give birth. hawrawh \'h\' baipata, sah = hot, warm. hawrawh \'â\' luhchhôpata, sâ = hair, unit, slightly bigger. hawrawh \'h\' bai heihpata sâh = rice, paddy, scream, cry out, shriek, thousand, high, howl, bird sings.\n\n'
              '9.  sao = net, rainy season, walk in river course, bunch of fruit. Hawrawh \'h\' baipata, saoh = point, poke, squeeze, milking. Saohpâpata = to shoot a gun at blank point.\n\n'
              '10. saw = son, offspring, pain with an effect of iodine. Hawrawh \'h\' baipata, sawh = unnatural death, unusual raibow on western side to indicate bad omen.\n\n'
              '11. vei = no, not, fart, slight touching, mental worry for someone or something. Hawrawh \'h\' baipata veih = juicy, fruitful, (in case of fruit juice) productive.\n\n'
              '12. za = respect, revere, shy, ticklish, hundred, an expression indicating downward or lower side. Hawrawh \'â\' luhchhôpata, zâ = ooze, ooze out, night, penis, expanding, elastic, escape through loop-hole. zâcho = midnight. Hawrawh \'h\' bai heihpata, zâh = distribution (of meat to the public).',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),

            // Concluding Paragraphs
            const Text(
              'He hawhta âsohsi kawpata roh awpah abyuh. Chataleipa khiata cha a bie yzie phie alei khai ha aw. These types of similar words are so many and these are the examples of selected few; they need to be properly differentiated, otherwise the meaning of a sentence will completely fail to express what one is intending to say.\n\n'
              'Âdopata cha Marâh reih mohchho zydua rôta yzie nanopa a hnei khai. Chavâta mohchho phichhyh byuhpa nata taopathi byuhpa a hluhpi a y. Reih hropa âla (adopt) awpah he ngiaroh leipa ei sila a pha thlyu aw. Sâhbaw, kawlaw, mawzâ, pihsi, mua, mawtaw, peraw, nawhbaw, dawhty, dawkâh, chini, peimawh, sinemâ, baisakaw, fubaw, hawki, (hla) ki, bemitaw, rizâpa, ezâhna, dailuah, kawfi, kaoh-â, raifuh, roket, bene (chaizôh), fi, hlawvâh, sili (ceiling), jake, jin, elektik, eleksawn, vaw, kamera, sanâh, etc., etc., he zydua chhao he reih hropa tawhta âlapa ama châ khai.\n\n'
              'Achhâchaina liata, he châbu papitlohsa awpahta nâ baotuhpa Puhpazy, IP.Junior, S Pailei, nata R.T. Zachônô, CEM parohpa nata achâhaipa-zy nata Puhpa N.Zakhai EM, Siaha, zy hnohta alyna bie ei reih hmeiseih.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 24),

            // Author Sign-off
            const Align(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Marâh reih hrohparei mawh sy.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Dated Guwahati,\nthe 20th Sept. 2013.',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'P.T. Hlychho, Author.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
