object todoCastillos {
	var castillos = []
	
	method castillos()  = castillos
	
	method agregarCastillo(castillo) {
		castillos.add(castillo)
	}
	
	method resistenciasCastillos() {
		return castillos.map({castillo => castillo.resistencia() })
	}
	
	method castilloConMinimaRes(buscador) {
		return castillos.filter({ i => i != buscador }).min({ castillo => castillo.resistencia() })
	}
}

class Castillo {
	var lider = new Rey(castillo = self)
	var cocina = new Cocina(castillo = self)
	var patio = new Patio(castillo = self)
	var guardias = []
	var burocratas = []
	var estabilidad = 500
	var resistencia = 500
	var ambientes = [cocina, patio]
	
	// se agrega automaticamente a todoCastillos.
	constructor() {
		todoCastillos.agregarCastillo(self)
	}
	
	method estabilidad() = estabilidad
	method resistencia() = resistencia
	method cocina()		 = cocina
	method patio() 		 = patio
	method guardias()    = guardias
	method burocratas()  = burocratas	
	method derrotado()   = estabilidad < 100
	method lider()       = lider
	method estabilidad(_estabilidad) { estabilidad = _estabilidad }
	method resistencia(_resistencia) { resistencia = _resistencia }
	
	method prepararDefensas() {
		guardias.forEach({ guardia => estabilidad += guardia.capacidad() * 0.5 })
		burocratas.filter({ burocrata => burocrata.puedePlanificar() })
					.forEach({ burocrata => resistencia += burocrata.aniosExperiencia() * 20})
	}
	
	method cambiarAReina() {
		lider = new Reina(castillo = self)
	}
	
	method cambiarARey(){
		lider = new Rey(castillo = self)
	}
	
	method festejar() {
		guardias.forEach({ guardia => guardia.descansar() })
		// se asusta alguno de los burocratas que no este asustado.
		burocratas.filter({ burocrata => burocrata.asustado() })
					.forEach({ b => b.relajarse() })
	}
	
	method contratarGuardias(cuantos) {
		cuantos.times({ i => guardias.add(new Guardia(lugar = ambientes.anyOne())) })
	}
	
	method despedirGuardias(cuantos) {
		cuantos.times({ i => guardias.remove(guardias.get(0))})
	}
	
	method contratarCocineros(cant) {
		cocina.contratarCocineros(cant)
	}
	
	method contratarEntrenadores(cant) {
		patio.contratarEntrenadores(cant)
	}
	
	// los burocratas seran objetos individuales.
	method contratarBurocrata(burocrata) {
		burocratas.add(burocrata)
	}
	
	method despedirBurocrata(burocrata) {
		burocratas.remove(burocrata)
	}
	
	// es posible fiesta si la resistencia es mayor a 125 o 25% de 500 y 
	// con menos o la mitad de los burocratas asustados.
	method esPosibleFiesta() {
		return (estabilidad > 125) and (burocratas.filter({ b => b.asustado() }).size() <= burocratas.size() * 0.5)	
	}
	
	method atacar(objetivo) {
		if (!self.derrotado()){
			objetivo.prepararDefensas()
			objetivo.defender(self)
			// segun las caracteristicas del objetivo, sufrimos daño.
			// los guardias se agotan mas que los del objetivo porque el enemigo esta fortificado.
			// segun la resistencia, se agotan entonces.
			guardias.forEach({ guardia => guardia.atacarCastillo(objetivo) })
		}

	}

	method defender(atacante) {
		// la perdida de resistencia y estabilidad depende de
		//       cantidad de guardias nuestros y del atacante.
		//       resistencia actual
		// si tenemos mas guardias, estos no bajan la estabilidad o la resistencia
		
		//console.println(estabilidad)
		//console.println(self.diferenciaEjercitos(atacante))
		
		if (self.diferenciaEjercitos(atacante) > 0) {
			// Lo valancee un poco, funciona pero los valores que pierde
			// de estabilidad y resistencia varian debido al metodo prepararDefensas.
			// Hay veces que terminas con mas estabilidad y defensa despues del ataque.
			estabilidad = estabilidad - (self.diferenciaEjercitos(atacante) * 1500 / resistencia)
			resistencia = resistencia - (self.diferenciaEjercitos(atacante) * 5)
		}
		
		
		guardias.forEach({ guardia => guardia.defenderCastillo() })
		// los guardias que poseen energia 0 o menor despues de la pelea mueren o se retiran deshabilitados.
		guardias.filter({ guardia => guardia.energia() <= 0 }).forEach({ guardia => guardias.remove(guardia) })
		/* En cada ataque, alguno de los burocratas con poca exp. que no estaba asustado se asusta */
		var posiblesAsustar = burocratas.filter({ b => b.aniosExperiencia() < 10 })
											.filter({ burocrata => not burocrata.asustado() })
		if (posiblesAsustar != []){
			// asusto a alguno de los burocratas.
			posiblesAsustar.anyOne()
							.asustarse()
		}
	}
	
	method alimentarGuardias() {
		cocina.alimentarGuardias()
	}
	
	method entrenarGuardias() {
		patio.entrenarGuardias()
	}
	
	method diferenciaEjercitos(atacante) {
		return atacante.guardias().size() - self.guardias().size()
	}
}

class Patio {
	const castillo
	var entrenadores = []
	
	method castillo() = castillo
	
	method contratarEntrenadores(cant) {
		cant.times({ i => entrenadores.add(new Entrenador(patio = self)) })
	}

	method entrenarGuardias() {
		// cada cocinero alimenta a 5 guardias menos calificados		
		entrenadores.forEach({ c => c.entrenarGuardias() })
	}
}

class Entrenador {
	const patio
	
	// cada entrenador entrena a los 5 guardias con menos capacidad
	method entrenarGuardias(){
		5.times({ i =>
			var guardiaConMenosCapacidad = patio.castillo().guardias().min({ g => g.capacidad() })
			guardiaConMenosCapacidad.entrenar()
		})
	}
}

class Cocina {
	const castillo
	var cocineros = []
	
	method castillo() = castillo
	
	method contratarCocineros(cant) {
		cant.times({ i => cocineros.add(new Cocinero(cocina = self)) })
	}

	method alimentarGuardias() {
		cocineros.forEach({ c => c.alimentarGuardias() })
	}
}

class Cocinero {
	const cocina
		
	// cada cocinero alimenta a 10 guardias mas agotados.		
	method alimentarGuardias(){
		10.times({ i =>
			var guardiaMasAgotado = cocina.castillo().guardias().min({ g => g.energia() })
			guardiaMasAgotado.comer()
		})
	}
}

class Rey {
	var castillo
	
	method ordenarFiesta() {
		if (castillo.esPosibleFiesta()) {
			castillo.festejar()
		}
	}
	
	method buscarObjetivo(){
		return todoCastillos.castilloConMinimaRes(castillo)
	}
}

class Reina {
	var castillo
	
	method ordenarFiesta() {
		// la reina es mas carismatica, por lo que la fiesta sucede si o si.
		castillo.festejar()
	}
	
	method inspirarGuardias() {
		// la reina es capaz de insipirar a los guardias
		// desaciendose aumentando su energia.
		castillo.guardias().forEach({ g => g.inspirarse() })
	}
	
	// buscar objetivo no cambia
	method buscarObjetivo(){
		return todoCastillos.castilloConMinimaRes(castillo)
	}
}

class Guardia {
	var energia = 100
	var capacidad = 5
	var lugar
	
	method capacidad() = capacidad
	method energia() = energia
	
	method energia(_energia) {
		energia = _energia
	}
	
	method descansar() {
		energia = 100
	}
	
	method defenderCastillo() {
		energia -= 25
	}
	
	method comer(){
		energia += 20
	}
	
	method inspirarse() {
		energia += 50
	}
	
	method entrenar() {
		capacidad += 5
	}
	
	method atacarCastillo(objetivo) {
		energia -= objetivo.resistencia() * 0.05
	}
}

class Burocrata {
	var nombre
	var fechaDeNacimiento
	var aniosExperiencia
	var estaAsustado = false
	
	method nombre() = nombre
	method aniosExperiencia() = aniosExperiencia
	method puedePlanificar() = not estaAsustado
	method asustado() = estaAsustado
	method relajarse() { estaAsustado = false }
	method asustarse() { estaAsustado = true }
}