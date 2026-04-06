/// Représente l'unité administrative la plus petite : le Canton.
class Canton {
  final String nom;
  const Canton({required this.nom});
}

/// Représente une Commune, qui est un regroupement de Cantons.
class Commune {
  final String nom;
  final List<Canton> cantons;
  const Commune({required this.nom, required this.cantons});
}

/// Représente une Préfecture, qui est un regroupement de Communes.
class Prefecture {
  final String nom;
  final List<Commune> communes;
  const Prefecture({required this.nom, required this.communes});
}

/// Représente une Région, l'unité administrative la plus grande.
class Region {
  final String nom;
  final List<Prefecture> prefectures;
  const Region({required this.nom, required this.prefectures});
}


// --- 2. Données Administratives Complètes du Togo ---

/// La liste complète des régions du Togo, avec leurs subdivisions.
/// Cette variable est prête à être importée et utilisée dans l'application.
final List<Region> togoData = [
  //==================== REGION MARITIME ====================
  Region(
    nom: "Maritime",
    prefectures: [
      Prefecture(
        nom: "Agoè-Nyivé",
        communes: [
          Commune(
            nom: "Agoè-Nyivé 1",
            cantons: [
              const Canton(nom: "ADJOUGBA"),
              const Canton(nom: "ADOUIKO"),
              const Canton(nom: "AHONGAKOPE ASSIYEYE"),
              const Canton(nom: "ANOKUI"),
              const Canton(nom: "ANOKUI NOGO"),
              const Canton(nom: "ANOME GBONVE"),
              const Canton(nom: "ANOMEGBLE"),
              const Canton(nom: "APEGNIGBI"),
              const Canton(nom: "ATSANVE"),
              const Canton(nom: "BOTOKOPE"),
              const Canton(nom: "DEMAKPOE"),
              const Canton(nom: "DJIGBLE"),
              const Canton(nom: "FIOVI"),
              const Canton(nom: "GNAMASSIGAN +ZOGBEGAN"),
              const Canton(nom: "HOUMBI"),
              const Canton(nom: "HOUMBIGBLE"),
              const Canton(nom: "KELEGOUGAN DIGBLE"),
              const Canton(nom: "KITIDJAN"),
              const Canton(nom: "KLEVE"),
              const Canton(nom: "KOVE APELEBUIME"),
              const Canton(nom: "KPATEFI"),
              const Canton(nom: "LOGOPE"),
              const Canton(nom: "LOGOPE ATSANVE"),
              const Canton(nom: "LOGOPE ΚΡΑTEFI"),
              const Canton(nom: "NYAVIME AvéYIME"),
              const Canton(nom: "NYIVEME + APELEBUIME"),
              const Canton(nom: "SOGBOSSITO"),
              const Canton(nom: "SOGBOSSITO AZIALE KOPE"),
              const Canton(nom: "TELESSOU"),
              const Canton(nom: "TELESSOU ADOKPO KOPE"),
              const Canton(nom: "TOGOME"),
              const Canton(nom: "TOTSI KLEVEGBLE"),
              const Canton(nom: "TOTSI KPATEFI"),
              const Canton(nom: "TOTSI NYIVEME"),
            ],
          ),
          Commune(
            nom: "Agoè-Nyivé 2",
            cantons: [
              const Canton(nom: "AGOSSITO"),
              const Canton(nom: "ΑΗΟΝΚΡΟΕ"),
              const Canton(nom: "AMADENTA ANAGLI KOPE"),
              const Canton(nom: "AMEDENTA AΚΙ ΚΟΡΕ"),
              const Canton(nom: "ASSIKO"),
              const Canton(nom: "ATHIEME"),
              const Canton(nom: "ATHIEME AHONKPOE"),
              const Canton(nom: "AVINATO"),
              const Canton(nom: "ΒΟΚΡΟΚΟ"),
              const Canton(nom: "DALIKO"),
              const Canton(nom: "DALIME"),
              const Canton(nom: "DOUTHE KOPE"),
              const Canton(nom: "KOVE AHONDJI KOPE"),
              const Canton(nom: "KOVE SIVAGNON KOPE"),
              const Canton(nom: "KPOKPLOVIME"),
              const Canton(nom: "LEGBASSITO"),
              const Canton(nom: "MADJIKPETO"),
              const Canton(nom: "SILIVI KOPE ou ADIDOME"),
              const Canton(nom: "YOHONOU"),
              const Canton(nom: "ZOVADJIN"),
            ],
          ),
          Commune(
            nom: "Agoè-Nyivé 3",
            cantons: [
                const Canton(nom: "ATSANVE"),
                const Canton(nom: "AWOUDJA KOPE"),
                const Canton(nom: "ELAVANYO ATSANVE"),
                const Canton(nom: "ELAVANYO KLEVE"),
                const Canton(nom: "HOSSOUKOPE"),
            ],
          ),
          Commune(
            nom: "Agoè-Nyivé 4",
            cantons: [
                const Canton(nom: "AKOIN"),
                const Canton(nom: "ALINKA"),
                const Canton(nom: "ALINKA NYIVEMEGBLE"),
                const Canton(nom: "ATSANVE"),
                const Canton(nom: "AvéYIME"),
                const Canton(nom: "BOKOR KOPE"),
                const Canton(nom: "DEGOME"),
                const Canton(nom: "DIKAME"),
                const Canton(nom: "DJELEDZI"),
                const Canton(nom: "FIDOKPUI"),
                const Canton(nom: "GUENOU KOPE"),
                const Canton(nom: "HAOUSSA ZONGO"),
                const Canton(nom: "KOTOKOLI ZONZO"),
                const Canton(nom: "KPEDEVI KOPE"),
                const Canton(nom: "TOGBLE CENTRE"),
                const Canton(nom: "TOWOUGANOU"),
            ],
          ),
          Commune(
            nom: "Agoè-Nyivé 5",
            cantons: [
                const Canton(nom: "AFIADEGNIGBA"),
                const Canton(nom: "AGBLELIKO"),
                const Canton(nom: "ANYIGBE"),
                const Canton(nom: "ASSIGOME"),
                const Canton(nom: "ATIGAN COPE"),
                const Canton(nom: "DANGBESSITO"),
                const Canton(nom: "DEKPO SANGUERA"),
                const Canton(nom: "EZION KOPE"),
                const Canton(nom: "KLEME SANGUERA"),
                const Canton(nom: "KLIKAME"),
                const Canton(nom: "KOHE"),
                const Canton(nom: "KOPEGAN"),
                const Canton(nom: "NANEGBE"),
                const Canton(nom: "NANEGBE ZOSSIME"),
                const Canton(nom: "SANYRAKO"),
                const Canton(nom: "TAGA KOPE"),
                const Canton(nom: "TSROKPOSSIME"),
                const Canton(nom: "VOGOME"),
                const Canton(nom: "ZOPOMAHE"),
            ],
          ),
           Commune(
            nom: "Agoè-Nyivé 6",
            cantons: [
                const Canton(nom: "ADETIKOPE-CENTRE"),
                const Canton(nom: "ADOGLOVE"),
                const Canton(nom: "AGNAvé"),
                const Canton(nom: "AGOTIME"),
                const Canton(nom: "DEVIME"),
                const Canton(nom: "DZOVE"),
                const Canton(nom: "KLADJEME"),
                const Canton(nom: "KPOKPOME-AGUTE"),
                const Canton(nom: "KPOTAvé"),
                const Canton(nom: "LOMENYO KOPE"),
                const Canton(nom: "TONOUKOUTI"),
                const Canton(nom: "TSIKPLONOU-KONDJI"),
            ],
          ),
        ],
      ),
      Prefecture(
        nom: "Golfe",
        communes: [
            Commune(
                nom: "Golfe 1",
                cantons: [
                    const Canton(nom: "AMOUTIVE BE KPEHENOU"),
                    const Canton(nom: "BE ABLOGAME"),
                    const Canton(nom: "BE ADAKPAME"),
                    const Canton(nom: "BE AKODESSEWA"),
                    const Canton(nom: "BE AKODESSEWA ΚΡΟΝOU"),
                    const Canton(nom: "BE AKODESSEWA ΚΡΟΤΑ"),
                    const Canton(nom: "BE ANFAME"),
                    const Canton(nom: "BE ΑΝΤΟΝΙΟ NETIME"),
                    const Canton(nom: "BE ATIEGOU"),
                    const Canton(nom: "BE"),
                    const Canton(nom: "BE AHLIGO"),
                    const Canton(nom: "BE APEYEME"),
                    const Canton(nom: "BE HEDJE"),
                    const Canton(nom: "BE ΚΡΟΤΑ"),
                    const Canton(nom: "GBENYEDJI"),
                    const Canton(nom: "BE ΚΑΝΥΙΚΟΡΕ"),
                    const Canton(nom: "BE KELEGOUGAN NORD"),
                    const Canton(nom: "BE KLOBATEME"),
                    const Canton(nom: "BE KOTOKOU KONDJI"),
                    const Canton(nom: "BE N'TIFAFA KOME"),
                    const Canton(nom: "BE SOUZA NETIME"),
                    const Canton(nom: "BE WETE"),
                    const Canton(nom: "BE ZONE PORTUAIRE"),
                ],
            ),
            Commune(
                nom: "Golfe 2",
                cantons: [
                    const Canton(nom: "BE=HEDZRANAWOE"),
                    const Canton(nom: "BEKELEGOUGAN"),
                    const Canton(nom: "BE SAINT JOSEPH"),
                    const Canton(nom: "BE TOKOIN AEROPORT"),
                    const Canton(nom: "BE=TOKOIN FOREVER"),
                    const Canton(nom: "BE=TOKOIN N'KAFU"),
                    const Canton(nom: "BE=TOKOIN TAME"),
                    const Canton(nom: "BE=TOKOIN WUITI"),
                ],
            ),
             Commune(
                nom: "Golfe 3",
                cantons: [
                    const Canton(nom: "BE DOUMASSESSE"),
                    const Canton(nom: "BE GBONVIE"),
                    const Canton(nom: "BE LOME II"),
                    const Canton(nom: "BE RESIDENCE DU BENIN"),
                    const Canton(nom: "BE TOKOIN ELAVAGNON"),
                    const Canton(nom: "BE TOKOIN LYCEE"),
                    const Canton(nom: "BE UNIVERSITE DE LOME"),
                ],
            ),
            Commune(
                nom: "Golfe 4",
                cantons: [
                    const Canton(nom: "AFLAO GAKLI AKOSSOMBO"),
                    const Canton(nom: "AFLAO GAKLI CASABLANCA"),
                    const Canton(nom: "AFLAO GAKLI TOKOIN SOLIDARITE"),
                    const Canton(nom: "AMOUTIVE ABOBOKOME"),
                    const Canton(nom: "AMOUTIVE ABOVE"),
                    const Canton(nom: "AMOUTIVE ADAWLATO"),
                    const Canton(nom: "AMOUTIVE ADOBOUKOME"),
                    const Canton(nom: "AMOUTIVE AGBADAHONOU"),
                    const Canton(nom: "AMOUTIVE AGUIAKOME"),
                    const Canton(nom: "AMOUTIVE AMOUTIVE"),
                    const Canton(nom: "AMOUTIVE BASSADJI"),
                    const Canton(nom: "AMOUTIVE BE KLIKAME"),
                    const Canton(nom: "AMOUTIVE BENIGLATO"),
                    const Canton(nom: "AMOUTIVE DOULASSAME"),
                    const Canton(nom: "AMOUTIVE FREAU JARDIN"),
                    const Canton(nom: "AMOUTIVE HANOUKOPE"),
                    const Canton(nom: "AMOUTIVE KODJOVIAKOPE"),
                    const Canton(nom: "AMOUTIVE KOKETIME"),
                    const Canton(nom: "AMOUTIVE LOM NAVA"),
                    const Canton(nom: "AMOUTIVE NΥΕΚΟΝΑΚΡΟΕЕ"),
                    const Canton(nom: "AMOUTIVE OCTAVIONO NETIME"),
                    const Canton(nom: "AMOUTIVE QUARTIER ADMINISTRATIF"),
                    const Canton(nom: "AMOUTIVE SANGUERA"),
                    const Canton(nom: "AMOUTIVE TOKOIN GBADAGO"),
                    const Canton(nom: "AMOUTIVE TOKOIN HOPITAL"),
                    const Canton(nom: "AMOUTIVE TOKOIN OUEST"),
                    const Canton(nom: "AMOUTIVE WETRIVI KONDJI"),
                    const Canton(nom: "BE DOGBEAVOU"),
                ],
            ),
             Commune(
                nom: "Golfe 5",
                cantons: [
                    const Canton(nom: "AFLAO GAKLI ADIDOADIN"),
                    const Canton(nom: "AFLAO GAKLI AFLAO GAKLI"),
                    const Canton(nom: "AFLAO GAKLI AGBALEPEDOGAN"),
                    const Canton(nom: "AFLAO GAKLI AMADAHOME"),
                    const Canton(nom: "AFLAO GAKLI ANYIGBE"),
                    const Canton(nom: "AFLAO GAKLI APEDOKOE"),
                    const Canton(nom: "AFLAO GAKLI AVEDJI TELESSOU"),
                    const Canton(nom: "AFLAO GAKLI AVENOU BATOME"),
                    const Canton(nom: "AFLAO GAKLI SOVIEPE"),
                    const Canton(nom: "AFLAO GAKLI TESHIE"),
                    const Canton(nom: "AFLAO GAKLI TOTSI"),
                    const Canton(nom: "AFLAO GAKLI WESSOME"),
                ],
            ),
            Commune(
                nom: "Golfe 6",
                cantons: [
                    const Canton(nom: "BAGUIDA ADAMAVO"),
                    const Canton(nom: "BAGUIDA AGODEKE"),
                    const Canton(nom: "BAGUIDA AVEPOZO"),
                    const Canton(nom: "BAGUIDA BAGUIDA"),
                    const Canton(nom: "BAGUIDA DEVEGO"),
                    const Canton(nom: "BAGUIDA KPOGAN"),
                ],
            ),
            Commune(
                nom: "Golfe 7",
                cantons: [
                    const Canton(nom: "AFLAO-SAGBADO ABLOGOME"),
                    const Canton(nom: "AFLAO-SAGBADO AGOTIME"),
                    const Canton(nom: "AFLAO-SAGBADO AKATO AVOEME"),
                    const Canton(nom: "AFLAO-SAGBADO AKATO DEME"),
                    const Canton(nom: "AFLAO-SAGBADO AKATO VIEPE"),
                    const Canton(nom: "AFLAO-SAGBADO APEDOKOE AGOKPANOU"),
                    const Canton(nom: "AFLAO-SAGBADO APEDOKOE GBOMAME"),
                    const Canton(nom: "AFLAO-SAGBADO AWATAME"),
                    const Canton(nom: "AFLAO-SAGBADO DEKPOR WOUGOME DEKPOR"),
                    const Canton(nom: "AFLAO-SAGBADO GBLENKOMEGAN"),
                    const Canton(nom: "AFLAO-SAGBADO KLEME AGOKPANOU"),
                    const Canton(nom: "AFLAO-SAGBADO KLEME YEWEPE"),
                    const Canton(nom: "AFLAO-SAGBADO LANKOUVI"),
                    const Canton(nom: "AFLAO-SAGBADO LANKOUVI SAKANI"),
                    const Canton(nom: "AFLAO-SAGBADO LOGOTE"),
                    const Canton(nom: "AFLAO-SAGBADO SAGBADO"),
                    const Canton(nom: "AFLAO-SAGBADO SAGBADO ASSIYEYE"),
                    const Canton(nom: "AFLAO-SAGBADO SAGBADO ZANVI"),
                    const Canton(nom: "AFLAO-SAGBADO SEGBE DOUANE"),
                    const Canton(nom: "AFLAO-SAGBADO SEGBEGAN"),
                    const Canton(nom: "AFLAO-SAGBADO WONYOME"),
                    const Canton(nom: "AFLAO-SAGBADO WOUGOME"),
                    const Canton(nom: "AFLAO-SAGBADO YOKOE AGBLEGAN"),
                    const Canton(nom: "AFLAO-SAGBADO YOKOE KOPEGAN"),
                ],
            ),
        ],
      ),
       Prefecture(
        nom: "Avé",
        communes: [
            Commune(
                nom: "Avé 1",
                cantons: [
                    const Canton(nom: "ANDO"),
                    const Canton(nom: "ASSAHOUN"),
                    const Canton(nom: "DZOLO"),
                    const Canton(nom: "KEVE"),
                    const Canton(nom: "TOVEGAN"),
                    const Canton(nom: "EDZI"),
                ],
            ),
            Commune(
                nom: "Avé 2",
                cantons: [
                    const Canton(nom: "AKEPE"),
                    const Canton(nom: "BADJA"),
                    const Canton(nom: "NOEPE"),
                ],
            ),
        ],
       ),
        Prefecture(
            nom: "Bas-Mono",
            communes: [
                Commune(
                    nom: "Bas-Mono 1",
                    cantons: [
                        const Canton(nom: "AFAGNAGAN"),
                        const Canton(nom: "AFAGNAN"),
                        const Canton(nom: "AGOME-GLOZOU"),
                        const Canton(nom: "KPETSOU"),
                    ],
                ),
                Commune(
                    nom: "Bas-Mono 2",
                    cantons: [
                        const Canton(nom: "AGBETIKO"),
                        const Canton(nom: "ATTITOGON"),
                        const Canton(nom: "HOMPOU"),
                    ],
                ),
            ],
        ),
        Prefecture(
            nom: "Lacs",
            communes: [
                Commune(nom: "Lacs 1", cantons: [const Canton(nom: "ANEHO"), const Canton(nom: "GLIDJI")]),
                Commune(nom: "Lacs 2", cantons: [const Canton(nom: "AGOUEGAN"), const Canton(nom: "AKLAKOU")]),
                Commune(nom: "Lacs 3", cantons: [const Canton(nom: "AGBODRAFO"), const Canton(nom: "GBODJOME")]),
                Commune(nom: "Lacs 4", cantons: [const Canton(nom: "ANFOIN"), const Canton(nom: "FIATA"), const Canton(nom: "GANAVE")]),
            ],
        ),
        Prefecture(
            nom: "Vo",
            communes: [
                Commune(nom: "Vo 1", cantons: [const Canton(nom: "VO-KOUTIME"), const Canton(nom: "VOGAN")]),
                Commune(nom: "Vo 2", cantons: [const Canton(nom: "ANYRON KOPE"), const Canton(nom: "TOGOVILLE")]),
                Commune(nom: "Vo 3", cantons: [const Canton(nom: "DAGBATI"), const Canton(nom: "DZREKPO"), const Canton(nom: "MOME-HOUNKPATI")]),
                Commune(nom: "Vo 4", cantons: [const Canton(nom: "AKOUMAPE"), const Canton(nom: "HAHOTOE"), const Canton(nom: "SEVAGAN")]),
            ],
        ),
         Prefecture(
            nom: "Yoto",
            communes: [
                Commune(nom: "Yoto 1", cantons: [const Canton(nom: "AMOUSSIME"), const Canton(nom: "KINI-KONDJI"), const Canton(nom: "TABLIGBO"), const Canton(nom: "KOUVE")]),
                Commune(nom: "Yoto 2", cantons: [const Canton(nom: "AHEPE"), const Canton(nom: "TCHEKPO"), const Canton(nom: "ZAFI")]),
                Commune(nom: "Yoto 3", cantons: [const Canton(nom: "ESSE-GODJIN"), const Canton(nom: "GBOTO"), const Canton(nom: "SEDOME"), const Canton(nom: "TOKPLI"), const Canton(nom: "TOMETY-KONDJI")]),
            ],
        ),
        Prefecture(
            nom: "Zio",
            communes: [
                Commune(nom: "Zio 1", cantons: [const Canton(nom: "ABOBO"), const Canton(nom: "DALAVE"), const Canton(nom: "DAVIE"), const Canton(nom: "DJAGBLE"), const Canton(nom: "GBATOPE"), const Canton(nom: "GBLAINVIE"), const Canton(nom: "KPOME"), const Canton(nom: "TSEVIE")]),
                Commune(nom: "Zio 2", cantons: [const Canton(nom: "BOLOU"), const Canton(nom: "KOVIE"), const Canton(nom: "MISSION-TOVE"), const Canton(nom: "WLI")]),
                Commune(nom: "Zio 3", cantons: [const Canton(nom: "AGBELOUVE"), const Canton(nom: "GAME")]),
                Commune(nom: "Zio 4", cantons: [const Canton(nom: "GAPE-CENTRE"), const Canton(nom: "GAPE-KPODJI")]),
            ],
        ),
    ],
  ),
  
  //==================== REGION PLATEAUX ====================
  Region(
    nom: "Plateaux",
    prefectures: [
      Prefecture(
        nom: "Agou",
        communes: [
            Commune(
                nom: "Agou 1",
                cantons: [
                    const Canton(nom: "ADJAHUN FIAGBE"),
                    const Canton(nom: "AGOU ATIGBE"),
                    const Canton(nom: "AGOU KEBO"),
                    const Canton(nom: "AGOU TAVIE"),
                    const Canton(nom: "AGOU YIBOE"),
                    const Canton(nom: "AGOU-AKPLOLO"),
                    const Canton(nom: "GADJA"),
                    const Canton(nom: "KATI"),
                    const Canton(nom: "NYOGBO-NORD (AGOU- NYOGBO AGBETIKO)"),
                    const Canton(nom: "NYOGBO-SUD (AGOU NYOGBO DZIDJOLE)"),
                ],
            ),
            Commune(
                nom: "Agou 2",
                cantons: [
                    const Canton(nom: "ADZAKPA"),
                    const Canton(nom: "AGOTIME NORD"),
                    const Canton(nom: "AMOUSSOU KOPE"),
                ],
            ),
        ],
      ),
      Prefecture(
        nom: "Akébou",
        communes: [
            Commune(
                nom: "Akébou 1",
                cantons: [
                    const Canton(nom: "DJON"),
                    const Canton(nom: "GBENDE"),
                    const Canton(nom: "KOUGNOHOU"),
                    const Canton(nom: "VHE"),
                    const Canton(nom: "YALLA"),
                ],
            ),
             Commune(
                nom: "Akébou 2",
                cantons: [
                    const Canton(nom: "KAMINA"),
                    const Canton(nom: "KPALAVE"),
                    const Canton(nom: "SEREGBENE"),
                ],
            ),
        ],
      ),
       Prefecture(
        nom: "Amou",
        communes: [
            Commune(
                nom: "Amou 1",
                cantons: [
                    const Canton(nom: "ADIVA"),
                    const Canton(nom: "IMLE"),
                    const Canton(nom: "OUMA-AMLAME"),
                ],
            ),
            Commune(
                nom: "Amou 2",
                cantons: [
                    const Canton(nom: "AMOU-OBLO"),
                    const Canton(nom: "EKPEGNON"),
                    const Canton(nom: "KPATEGAN"),
                    const Canton(nom: "SODO"),
                ],
            ),
            Commune(
                nom: "Amou 3",
                cantons: [
                    const Canton(nom: "AVEDJE-ITADI"),
                    const Canton(nom: "EVOU"),
                    const Canton(nom: "GAME"),
                    const Canton(nom: "HIHEATRO"),
                    const Canton(nom: "OKPAHOE"),
                    const Canton(nom: "OTADI"),
                    const Canton(nom: "TEMEDJA"),
                ],
            ),
        ],
       ),
       Prefecture(
        nom: "Anié",
        communes: [
            Commune(
                nom: "Anié 1",
                cantons: [
                    const Canton(nom: "ANIE"),
                    const Canton(nom: "KOLO-KOPE"),
                    const Canton(nom: "PALLAKOKO"),
                ],
            ),
            Commune(
                nom: "Anié 2",
                cantons: [
                    const Canton(nom: "ADOGBENOU"),
                    const Canton(nom: "ATCHINEDJI"),
                    const Canton(nom: "GLITTO"),
                ],
            ),
        ],
       ),
       Prefecture(
        nom: "Danyi",
        communes: [
            Commune(
                nom: "Danyi 1",
                cantons: [
                    const Canton(nom: "DANYI-ELAVANYO"),
                    const Canton(nom: "DANYI-KAKPA"),
                    const Canton(nom: "YIKPA"),
                ],
            ),
             Commune(
                nom: "Danyi 2",
                cantons: [
                    const Canton(nom: "AHLON"),
                    const Canton(nom: "DANYI KPETO-EVITA"),
                    const Canton(nom: "DANYI-ATIGBA"),
                ],
            ),
        ],
       ),
       Prefecture(
        nom: "Est-Mono",
        communes: [
            Commune(
                nom: "Est-Mono 1",
                cantons: [
                    const Canton(nom: "ELAVAGNON"),
                    const Canton(nom: "GBADJAHE"),
                ],
            ),
            Commune(
                nom: "Est-Mono 2",
                cantons: [
                    const Canton(nom: "BADIN"),
                    const Canton(nom: "KAMINA"),
                    const Canton(nom: "MORETAN"),
                ],
            ),
             Commune(
                nom: "Est-Mono 3",
                cantons: [
                    const Canton(nom: "KPESSI"),
                    const Canton(nom: "NYAMASSILA"),
                ],
            ),
        ],
       ),
       Prefecture(
        nom: "Haho",
        communes: [
            Commune(
                nom: "Haho 1",
                cantons: [
                    const Canton(nom: "ATCHAVE"),
                    const Canton(nom: "DALIA"),
                    const Canton(nom: "HAHOMEGBE"),
                    const Canton(nom: "NOTSE"),
                ],
            ),
            Commune(
                nom: "Haho 2",
                cantons: [
                    const Canton(nom: "ASRAMA"),
                    const Canton(nom: "DJEMEGNI"),
                ],
            ),
            Commune(
                nom: "Haho 3",
                cantons: [
                    const Canton(nom: "AKPAKPAKPE"),
                    const Canton(nom: "KPEDOME"),
                ],
            ),
            Commune(
                nom: "Haho 4",
                cantons: [
                    const Canton(nom: "AYITO"),
                    const Canton(nom: "WAHALA"),
                ],
            ),
        ],
       ),
       Prefecture(
        nom: "Kloto",
        communes: [
            Commune(
                nom: "Kloto 1",
                cantons: [
                    const Canton(nom: "AGOME KPALIME"),
                    const Canton(nom: "GBALAVE"),
                    const Canton(nom: "HANYIGBA"),
                    const Canton(nom: "KPADAPE"),
                    const Canton(nom: "TOME"),
                    const Canton(nom: "TOVE"),
                    const Canton(nom: "WOME"),
                    const Canton(nom: "YOKELE"),
                ],
            ),
            Commune(
                nom: "Kloto 2",
                cantons: [
                    const Canton(nom: "KPIME"),
                    const Canton(nom: "LAVIE"),
                    const Canton(nom: "LAVIE APEDOME"),
                ],
            ),
             Commune(
                nom: "Kloto 3",
                cantons: [
                    const Canton(nom: "AGOME-TOMEGBE"),
                    const Canton(nom: "KOUMA"),
                    const Canton(nom: "AGOME"),
                ],
            ),
        ],
       ),
        Prefecture(
            nom: "Kpélé",
            communes: [
                Commune(
                    nom: "Kpélé 1",
                    cantons: [
                        const Canton(nom: "AKATA"),
                        const Canton(nom: "KPELE-DAWLOTOU"),
                        const Canton(nom: "KPELE-GOVIE"),
                        const Canton(nom: "KPELE-NOVIVE"),
                    ],
                ),
                Commune(
                    nom: "Kpélé 2",
                    cantons: [
                        const Canton(nom: "KPELE-CENTRE/GOUDEVE"),
                        const Canton(nom: "KPELE-DUTOE"),
                        const Canton(nom: "KPELE-GBALADZE"),
                        const Canton(nom: "KPELE-KAME"),
                        const Canton(nom: "KPELE-NORD"),
                    ],
                ),
            ],
        ),
         Prefecture(
            nom: "Moyen-Mono",
            communes: [
                Commune(
                    nom: "Moyen-Mono 1",
                    cantons: [
                        const Canton(nom: "AHASSOME"),
                        const Canton(nom: "TADO"),
                        const Canton(nom: "TOHOUN"),
                    ],
                ),
                Commune(
                    nom: "Moyen-Mono 2",
                    cantons: [
                        const Canton(nom: "KATOME"),
                        const Canton(nom: "KPEKPLEME"),
                        const Canton(nom: "SALIGBE"),
                    ],
                ),
            ],
        ),
         Prefecture(
            nom: "Ogou",
            communes: [
                Commune(
                    nom: "Ogou 1",
                    cantons: [
                        const Canton(nom: "DJAMA"),
                        const Canton(nom: "GNAGNA"),
                        const Canton(nom: "WOUDOU"),
                    ],
                ),
                Commune(
                    nom: "Ogou 2",
                    cantons: [
                        const Canton(nom: "AKPARE"),
                        const Canton(nom: "DATCHA"),
                        const Canton(nom: "KATORE"),
                    ],
                ),
                Commune(nom: "Ogou 3", cantons: [const Canton(nom: "GLEI")]),
                Commune(nom: "Ogou 4", cantons: [const Canton(nom: "OUNTIVOU")]),
            ],
        ),
        Prefecture(
            nom: "Wawa",
            communes: [
                Commune(
                    nom: "Wawa 1",
                    cantons: [
                        const Canton(nom: "BADOU"),
                        const Canton(nom: "KESSIBO"),
                        const Canton(nom: "KPETE BENA"),
                        const Canton(nom: "TOMEGBE"),
                    ],
                ),
                 Commune(
                    nom: "Wawa 2",
                    cantons: [
                        const Canton(nom: "EKETO"),
                        const Canton(nom: "GBANDI-N'KOUGNA"),
                        const Canton(nom: "GOBE"),
                    ],
                ),
                Commune(
                    nom: "Wawa 3",
                    cantons: [
                        const Canton(nom: "DOUME"),
                        const Canton(nom: "KLABE EFOUKPA"),
                        const Canton(nom: "OKOU"),
                        const Canton(nom: "OUNABE"),
                        const Canton(nom: "ZOGBEGAN"),
                    ],
                ),
            ],
        ),
    ],
  ),
  
  //==================== REGION CENTRALE ====================
  Region(
    nom: "Centrale",
    prefectures: [
      Prefecture(
        nom: "Blitta",
        communes: [
          Commune(
            nom: "Blitta 1",
            cantons: [
              const Canton(nom: "BLITTA VILLAGE"),
              const Canton(nom: "BLITTA-GARE"),
              const Canton(nom: "DOUFOULI"),
              const Canton(nom: "PAGALA-GARE"),
              const Canton(nom: "TCHALOUDE"),
              const Canton(nom: "WARAGNI"),
              const Canton(nom: "YALOUMBE"),
            ],
          ),
          Commune(
            nom: "Blitta 2",
            cantons: [
              const Canton(nom: "AGBANDI"),
              const Canton(nom: "KOFFITI"),
              const Canton(nom: "LANGABOU"),
              const Canton(nom: "TCHARE-BAOU"),
            ],
          ),
          Commune(
            nom: "Blitta 3",
            cantons: [
              const Canton(nom: "ATCHINTSE"),
              const Canton(nom: "DIGUENGUE"),
              const Canton(nom: "KATCHENKE"),
              const Canton(nom: "M'POTI"),
              const Canton(nom: "PAGALA-VILLAGE"),
              const Canton(nom: "TCHIFAMA"),
              const Canton(nom: "TINTCHRO"),
              const Canton(nom: "WELLY"),
              const Canton(nom: "YEGUE"),
              const Canton(nom: "DIKPELEOU"),
            ],
          ),
        ],
      ),
      Prefecture(
        nom: "Mô",
        communes: [
          Commune(
            nom: "Mô 1",
            cantons: [
              const Canton(nom: "BOULOHOU"),
              const Canton(nom: "DJARKPANGA"),
              const Canton(nom: "KAGNIGBARA"),
            ],
          ),
          Commune(
            nom: "Mô 2",
            cantons: [
              const Canton(nom: "SAIBOUDE"),
              const Canton(nom: "TINDJASSI"),
            ],
          ),
        ],
      ),
      Prefecture(
        nom: "Sotouboua",
        communes: [
          Commune(
            nom: "Sotouboua 1",
            cantons: [
              const Canton(nom: "KANIAMBOUA"),
              const Canton(nom: "SOTOUBOUA"),
              const Canton(nom: "TABINDE"),
            ],
          ),
          Commune(
            nom: "Sotouboua 2",
            cantons: [
              const Canton(nom: "ADJENGRE"),
              const Canton(nom: "AOUDA"),
              const Canton(nom: "FAZAO"),
              const Canton(nom: "KERIADE"),
              const Canton(nom: "SESSARO"),
              const Canton(nom: "TITIGBE"),
            ],
          ),
          Commune(
            nom: "Sotouboua 3",
            cantons: [
              const Canton(nom: "BODJONDE"),
              const Canton(nom: "KAZABOUA"),
              const Canton(nom: "TCHEBEBE"),
            ],
          ),
        ],
      ),
      Prefecture(
        nom: "Tchamba",
        communes: [
          Commune(
            nom: "Tchamba 1",
            cantons: [
              const Canton(nom: "AFFEM"),
              const Canton(nom: "ALIBI"),
              const Canton(nom: "KRI-KRI (ADJEIDE)"),
              const Canton(nom: "LARNI"),
              const Canton(nom: "TCHAMBA"),
            ],
          ),
          Commune(
            nom: "Tchamba 2",
            cantons: [
              const Canton(nom: "BAGO"),
              const Canton(nom: "KOUSSOUNTOU"),
            ],
          ),
          Commune(
            nom: "Tchamba 3",
            cantons: [
              const Canton(nom: "BALANKA"),
              const Canton(nom: "GOUBI"),
              const Canton(nom: "KABOLI"),
            ],
          ),
        ],
      ),
      Prefecture(
        nom: "Tchaoudjo",
        communes: [
          Commune(
            nom: "Tchaoudjo 1",
            cantons: [
              const Canton(nom: "KADAMBARA"),
              const Canton(nom: "KOMAH"),
              const Canton(nom: "KPANGALAM"),
              const Canton(nom: "KPARATAO"),
              const Canton(nom: "TCHALO"),
            ],
          ),
          Commune(nom: "Tchaoudjo 2", cantons: [const Canton(nom: "LAMA-TESSI")]),
          Commune(
            nom: "Tchaoudjo 3",
            cantons: [
              const Canton(nom: "ALEHERIDE"),
              const Canton(nom: "AMAIDE"),
              const Canton(nom: "KEMENI"),
              const Canton(nom: "KOLINA"),
            ],
          ),
          Commune(
            nom: "Tchaoudjo 4",
            cantons: [
              const Canton(nom: "AGOULOU"),
              const Canton(nom: "KPASSOUADE"),
              const Canton(nom: "WASSARABO"),
            ],
          ),
        ],
      ),
    ],
  ),
  
  //==================== REGION DE LA KARA ====================
  Region(
    nom: "Kara",
    prefectures: [
      Prefecture(
        nom: "Assoli",
        communes: [
          Commune(
            nom: "Assoli 1",
            cantons: [
              const Canton(nom: "BAFILO"),
              const Canton(nom: "BOULADE"),
              const Canton(nom: "DAKO/DAOUDE"),
            ],
          ),
          Commune(
            nom: "Assoli 2",
            cantons: [
              const Canton(nom: "ALEDJO"),
              const Canton(nom: "KOUMONDE"),
            ],
          ),
          Commune(nom: "Assoli 3", cantons: [const Canton(nom: "SOUDOU")]),
        ],
      ),
      Prefecture(
        nom: "Bassar",
        communes: [
          Commune(
            nom: "Bassar 1",
            cantons: [
              const Canton(nom: "BAGHAN"),
              const Canton(nom: "BASSAR"),
              const Canton(nom: "KALANGA"),
            ],
          ),
          Commune(
            nom: "Bassar 2",
            cantons: [
              const Canton(nom: "BANGELI"),
              const Canton(nom: "BITCHABE"),
              const Canton(nom: "DIMORI"),
            ],
          ),
          Commune(
            nom: "Bassar 3",
            cantons: [
              const Canton(nom: "KABOU"),
              const Canton(nom: "MANGA"),
            ],
          ),
          Commune(
            nom: "Bassar 4",
            cantons: [
              const Canton(nom: "SANDA-AFOHOU"),
              const Canton(nom: "SANDA-KAGBANDA"),
            ],
          ),
        ],
      ),
      Prefecture(
        nom: "Binah",
        communes: [
          Commune(
            nom: "Binah 1",
            cantons: [
              const Canton(nom: "BOUFALE"),
              const Canton(nom: "LAMA-DESSI"),
              const Canton(nom: "PAGOUDA"),
              const Canton(nom: "PESSARE"),
              const Canton(nom: "PITIKITA"),
              const Canton(nom: "SOLLA"),
            ],
          ),
          Commune(
            nom: "Binah 2",
            cantons: [
              const Canton(nom: "KEMERIDA"),
              const Canton(nom: "KETAO"),
              const Canton(nom: "SIRKA"),
            ],
          ),
        ],
      ),
      Prefecture(
        nom: "Dankpen",
        communes: [
          Commune(
            nom: "Dankpen 1",
            cantons: [
              const Canton(nom: "GUERIN-KOUKA"),
              const Canton(nom: "KATCHAMBA"),
              const Canton(nom: "KOULFIEKOU"),
              const Canton(nom: "NAMPOCH"),
            ],
          ),
          Commune(
            nom: "Dankpen 2",
            cantons: [
              const Canton(nom: "KOUTCHITCHEOU"),
              const Canton(nom: "NAMON"),
              const Canton(nom: "NATCHIBORE"),
              const Canton(nom: "NATCHITIKPI"),
            ],
          ),
          Commune(
            nom: "Dankpen 3",
            cantons: [
              const Canton(nom: "BAPURE"),
              const Canton(nom: "KIDJABOUN"),
              const Canton(nom: "NANDOUTA"),
              const Canton(nom: "NAWARE"),
            ],
          ),
        ],
      ),
      Prefecture(
        nom: "Doufelgou",
        communes: [
          Commune(
            nom: "Doufelgou 1",
            cantons: [
              const Canton(nom: "AGBANDE-YAKA"),
              const Canton(nom: "BAGA"),
              const Canton(nom: "KOKA"),
              const Canton(nom: "MASSEDENA"),
              const Canton(nom: "NIAMTOUGOU"),
              const Canton(nom: "POUDA"),
              const Canton(nom: "SIOU"),
              const Canton(nom: "TENEGA"),
            ],
          ),
          Commune(
            nom: "Doufelgou 2",
            cantons: [
              const Canton(nom: "ALLOUM"),
              const Canton(nom: "KADJALLA"),
              const Canton(nom: "LEON"),
              const Canton(nom: "TCHORE"),
            ],
          ),
          Commune(
            nom: "Doufelgou 3",
            cantons: [
              const Canton(nom: "ANIMA"),
              const Canton(nom: "DEFALE"),
              const Canton(nom: "KPANA"),
            ],
          ),
        ],
      ),
      Prefecture(
        nom: "Kéran",
        communes: [
          Commune(
            nom: "Kéran 1",
            cantons: [
              const Canton(nom: "AKPONTE"),
              const Canton(nom: "KANDE"),
              const Canton(nom: "PESSIDE"),
            ],
          ),
          Commune(
            nom: "Kéran 2",
            cantons: [
              const Canton(nom: "ATALOTE"),
              const Canton(nom: "HELOTA"),
              const Canton(nom: "OSSACRE"),
            ],
          ),
          Commune(
            nom: "Kéran 3",
            cantons: [
              const Canton(nom: "KOUTOUGOU"),
              const Canton(nom: "NADOBA"),
              const Canton(nom: "WARENGO"),
            ],
          ),
        ],
      ),
      Prefecture(
        nom: "Kozah",
        communes: [
          Commune(
            nom: "Kozah 1",
            cantons: [
              const Canton(nom: "LAMA"),
              const Canton(nom: "LANDA"),
              const Canton(nom: "LASSA"),
              const Canton(nom: "SOUMDINA"),
            ],
          ),
          Commune(
            nom: "Kozah 2",
            cantons: [
              const Canton(nom: "BOHOU"),
              const Canton(nom: "KOUMEA"),
              const Canton(nom: "PYA"),
              const Canton(nom: "SARAKAWA"),
              const Canton(nom: "TCHARE"),
              const Canton(nom: "TCHITCHAO"),
              const Canton(nom: "YADE"),
            ],
          ),
          Commune(
            nom: "Kozah 3",
            cantons: [
              const Canton(nom: "AWANDJELO"),
              const Canton(nom: "KPINZINDE"),
            ],
          ),
          Commune(
            nom: "Kozah 4",
            cantons: [
              const Canton(nom: "ATCHANGBADE"),
              const Canton(nom: "DJAMDE"),
            ],
          ),
        ],
      ),
    ],
  ),
  
  //==================== REGION DES SAVANES ====================
  Region(
    nom: "Savanes",
    prefectures: [
      Prefecture(
        nom: "Cinkassé",
        communes: [
          Commune(
            nom: "Cinkassé 1",
            cantons: [
              const Canton(nom: "BOADE"),
              const Canton(nom: "CINKASSE"),
              const Canton(nom: "GNOAGA"),
              const Canton(nom: "GOULOUNGOUSSI"),
            ],
          ),
          Commune(
            nom: "Cinkassé 2",
            cantons: [
              const Canton(nom: "BIANKOURI"),
              const Canton(nom: "NADJOUNDI"),
              const Canton(nom: "SAM-NABA"),
              const Canton(nom: "TIMBOU"),
            ],
          ),
        ],
      ),
      Prefecture(
        nom: "Kpendjal",
        communes: [
          Commune(
            nom: "Kpendjal 1",
            cantons: [
              const Canton(nom: "KOUNDJOARE"),
              const Canton(nom: "MANDOURI"),
              const Canton(nom: "TAMBIGOU"),
            ],
          ),
          Commune(nom: "Kpendjal 2", cantons: [const Canton(nom: "BORGOU")]),
        ],
      ),
      Prefecture(
        nom: "Kpendjal-Ouest",
        communes: [
          Commune(
            nom: "Kpendjal-Ouest 1",
            cantons: [
              const Canton(nom: "NAKI-EST"),
              const Canton(nom: "NAYEGA"),
              const Canton(nom: "OGARO"),
            ],
          ),
          Commune(
            nom: "Kpendjal-Ouest 2",
            cantons: [
              const Canton(nom: "NAMOUNDJOGA"),
              const Canton(nom: "PAPRI"),
              const Canton(nom: "POGNO"),
              const Canton(nom: "TAMBONGA"),
            ],
          ),
        ],
      ),
      Prefecture(
        nom: "Oti",
        communes: [
          Commune(
            nom: "Oti 1",
            cantons: [
              const Canton(nom: "FARE"),
              const Canton(nom: "MANGO"),
              const Canton(nom: "SADORI"),
            ],
          ),
          Commune(
            nom: "Oti 2",
            cantons: [
              const Canton(nom: "BARKOISSI"),
              const Canton(nom: "GALANGASHIE"),
              const Canton(nom: "LOKO"),
              const Canton(nom: "NAGBENI"),
              const Canton(nom: "TCHANAGA"),
            ],
          ),
        ],
      ),
      Prefecture(
        nom: "Oti-Sud",
        communes: [
          Commune(
            nom: "Oti-Sud 1",
            cantons: [
              const Canton(nom: "GANDO"),
              const Canton(nom: "MOGOU"),
              const Canton(nom: "SAGBIEBOU"),
              const Canton(nom: "TCHAMONGA"),
            ],
          ),
          Commune(
            nom: "Oti-Sud 2",
            cantons: [
              const Canton(nom: "KOUMONGOU"),
              const Canton(nom: "KOUNTOIRE"),
              const Canton(nom: "NALI"),
              const Canton(nom: "TAKRAMBA"),
            ],
          ),
        ],
      ),
      Prefecture(
        nom: "Tandjouaré",
        communes: [
          Commune(
            nom: "Tandjouaré 1",
            cantons: [
              const Canton(nom: "LOKO"),
              const Canton(nom: "BOGOU"),
              const Canton(nom: "BOMBOUAKA"),
              const Canton(nom: "BOULOGOU"),
              const Canton(nom: "GOUNDOGA"),
              const Canton(nom: "NANDOGA"),
              const Canton(nom: "PLIGOU"),
              const Canton(nom: "TAMONGUE"),
            ],
          ),
          Commune(
            nom: "Tandjouaré 2",
            cantons: [
              const Canton(nom: "BAGOU"),
              const Canton(nom: "DOUKPERGOU"),
              const Canton(nom: "LOKPANO"),
              const Canton(nom: "MAMPROUGOU"),
              const Canton(nom: "NANO"),
              const Canton(nom: "SANGOU"),
              const Canton(nom: "SISSIAK"),
              const Canton(nom: "TAMPIALIME"),
            ],
          ),
        ],
      ),
      Prefecture(
        nom: "Tône",
        communes: [
          Commune(
            nom: "Tône 1",
            cantons: [
              const Canton(nom: "BIDJENGA"),
              const Canton(nom: "DAPAONG"),
              const Canton(nom: "KOURIENTRE"),
              const Canton(nom: "NATIGOU"),
              const Canton(nom: "PANA"),
              const Canton(nom: "POISSONGUI"),
              const Canton(nom: "TOAGA"),
            ],
          ),
          Commune(
            nom: "Tône 2",
            cantons: [
              const Canton(nom: "NAKI-OUEST"),
              const Canton(nom: "NAMARE"),
              const Canton(nom: "NANERGOU"),
            ],
          ),
          Commune(
            nom: "Tône 3",
            cantons: [
              const Canton(nom: "LOTOGOU"),
              const Canton(nom: "NIOUKPOURMA"),
              const Canton(nom: "TAMI"),
              const Canton(nom: "WARKAMBOU"),
            ],
          ),
          Commune(
            nom: "Tône 4",
            cantons: [
              const Canton(nom: "KANTINDI"),
              const Canton(nom: "KORBONGOU"),
              const Canton(nom: "LOUANGA"),
              const Canton(nom: "SANFATOUTE"),
            ],
          ),
        ],
      ),
    ],
  ),
];