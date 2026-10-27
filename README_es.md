# dotfiles de nixos

> última revisión: 2026-10-28 · [read in english](./README.md)

configuración personal de nixos gestionada como un flake. se construye a partir de módulos pequeños de `irene` que pueden activarse por separado o agruparse en suites.

## qué hay aquí

| ruta | propósito |
|------|-----------|
| `flake.nix` | entradas y `nixosConfigurations`. |
| `hosts/*/` | importaciones específicas del host, diseño de disco, hardware y módulos activados. |
| `homes/*/` | configuraciones de home-manager por usuario. |
| `modules/nixos/` | módulos de sistema reutilizables bajo el espacio de nombres `irene`. los de primer nivel (`boot`, `network`, `nvidia`, ...) los importa cada host. |
| `modules/nixos/programs/` | un módulo por programa, cada uno con una opción `irene.programs.<name>.enable`. |
| `modules/nixos/suites/` | grupos de programas bajo una sola opción `irene.suites.<name>.enable`. |
| `modules/home-manager/` | módulos de usuario reutilizables bajo el espacio de nombres `irene.home-manager`. |
| `templates/module/` | punto de partida para nuevos módulos. |
| `install.sh` | instala un host desde una iso live de nixos. borra un disco. |
| `CLAUDE.md` | convenciones y reglas para la ia que trabaja en este repositorio. |
| `LICENSE.txt` | licencia mit. |

## hosts

| host | descripción |
|------|-------------|
| `roxas` | máquina principal. gráficos híbridos intel + nvidia, todas las suites activadas. |
| `vm` | máquina virtual para pruebas. |

### estructura del host

`hosts/<name>/default.nix` importa disko, el módulo de nixos de home-manager, `disko.nix`, `hardware.nix` y `configuration.nix`. `configuration.nix` importa cada módulo de primer nivel que usa y define las opciones `irene.*`. `hardware.nix` está generado por `nixos-generate-config`.

### módulos y suites

los módulos están en capas: un módulo de programa (`modules/nixos/programs/<name>`) → una suite (`modules/nixos/suites/<name>`) que activa un grupo de programas → un host que activa suites. un programa nuevo se activa desde una suite, no desde el host.

un módulo de programa llamado `foo` expone `irene.programs.foo.enable` y aplica su configuración solo cuando la opción está activada:

```nix
options.irene.programs.foo.enable = lib.mkEnableOption "foo";

config = lib.mkIf config.irene.programs.foo.enable {
  programs.foo.enable = true;
};
```

una suite llamada `bar` agrupa módulos de programas bajo una sola opción, `irene.suites.bar.enable`.

para añadir un módulo, copia `templates/module/default.nix` y sustituye `namespace.module` por la ruta de opción real. los módulos no se descubren automáticamente: añade el nuevo a los `imports` del `default.nix` de su directorio padre. el flake solo ve los ficheros que git rastrea, así que haz `git add` de los ficheros nuevos antes de `nix flake check`.

### módulos de home-manager

home-manager está integrado como módulo de nixos, así que `nixos-rebuild switch` aplica tanto la configuración del sistema como la del usuario. los módulos de usuario viven en `modules/home-manager/`; la ruta de su opción refleja su ruta dentro de ese directorio:

```nix
options.irene.home-manager.foo.enable = lib.mkEnableOption "foo";

config = lib.mkIf config.irene.home-manager.foo.enable {
  programs.foo.enable = true;
};
```

un módulo en `modules/home-manager/foo/` expone `irene.home-manager.foo.enable`. los módulos se activan en `homes/<usuario>/default.nix`:

```nix
irene.home-manager.foo.enable = true;
```

## por qué esta configuración

el fichero del host se mantiene pequeño: decide qué capacidades activar, mientras que los módulos se encargan de la implementación. añadir un programa o un servicio no obliga a editar todos los hosts, y las suites describen una máquina por su rol en lugar de por una lista de paquetes.

disko mantiene el diseño de disco en el repositorio, de modo que el particionado es reproducible y no una secuencia de comandos manuales.

no escribo el código a mano. diseño la lógica y la ia lo ejecuta.

## inicio rápido

requiere nix con flakes activados.

### instalar

desde una iso live de nixos, con este repositorio disponible:

```bash
sudo ./install.sh [--disk /dev/disk/by-id/...] [host]
```

`host` es `roxas` por defecto. si `hosts/<host>/disko.nix` contiene `REPLACE-ME`, el instalador muestra un menú con los discos completos y guarda el elegido en ese fichero. **borra el disco seleccionado.**

### actualizar

en un sistema ya instalado, desde la raíz del repositorio:

```bash
nix flake check
alejandra .
sudo nixos-rebuild switch --flake .#<host>
```

`nixos-rebuild switch` aplica tanto la configuración del sistema como la de home-manager; no hace falta ejecutar `home-manager switch` por separado.

## recursos relacionados

- [manual de nixos (unstable)](https://nixos.org/manual/nixos/unstable/)
- [home-manager](https://nix-community.github.io/home-manager/)
- [disko](https://github.com/nix-community/disko)

## licencia

mit. consulta [`LICENSE.txt`](./LICENSE.txt).
