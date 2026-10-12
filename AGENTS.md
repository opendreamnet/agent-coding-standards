# Reglas de desarrollo compartidas

Este repositorio contiene exclusivamente las convenciones de desarrollo compartidas
que los repositorios de la empresa seleccionan para generar su `CODING.md`.
La CLI que instala y actualiza esas reglas vive en un repositorio independiente.

## Alcance

- Mantener reglas modulares en `rules/`, agrupadas por lenguaje o herramienta.
- Contemplar perfiles independientes como `typescript`, `vue` y `python`.
- Permitir componer solo los perfiles declarados por cada consumidor, en su orden,
  sin incorporar perfiles ni reglas de otros lenguajes de forma implícita.
- Escribir reglas claras, concretas y reutilizables, sin contexto particular de un
  proyecto. Ese contexto y sus excepciones pertenecen al `AGENTS.md` del consumidor.

## Versionado y cambios

- Publicar versiones identificables mediante tags SemVer, como `v1.0.0`.
- No mover ni reutilizar tags publicados: una misma versión debe producir las mismas reglas.
- Mantener independiente la versión de las reglas respecto a la versión de la CLI.
- No implementar aquí la CLI, automatizaciones de propagación ni archivos generados
  para repositorios consumidores.
- No crear commits, tags, releases, pushes ni PRs sin una solicitud explícita.
