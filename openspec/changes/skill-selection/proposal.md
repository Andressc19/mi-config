# Proposal: skill-selection

## Intent

El installer actual copia **todo** `configs/opencode/` sin opción de selección. Users no pueden instalar solo los skills SDD que necesitan, forzando una instalación "todo o nada".

## Scope

### In Scope
- Crear `configs/opencode/skills-manifest.json` con metadata de cada skill
- Agregar flags `--skills` y `--exclude-skills` a `install-opencode.sh` y `install-opencode.ps1`
- Implementar lógica de filtrado en scripts para copiar solo skills seleccionados
- Actualizar TUI en Go para pantalla de selección visual de skills

### Out of Scope
- Modificar el manifest de opencode.json
- Cambios en skills individuales

## Approach

1. Crear `skills-manifest.json` con id, name, required, description por skill
2. Scripts lean manifest, interpretan flags, copian subset
3. TUI usa selección multi-item (checkbox) para skills

## Skill Sources

El installer soporta skills de múltiples fuentes:

| Fuente | Formato | Ejemplo |
|--------|---------|---------|
| `local` | Ruta a archivo local | `/home/user/my-skill/SKILL.md` |
| `url` | URL directa | `https://raw.githubusercontent.com/.../SKILL.md` |

Las fuentes se definen en `skills-manifest.json` con campo `source`:

```json
{
  "id": "sdd-init",
  "name": "SDD Init",
  "source": "local",
  "path": "skills/sdd-init/SKILL.md"
}
```

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `configs/opencode/skills-manifest.json` | New | Manifest de skills |
| `scripts/install-opencode.sh` | Modified | Flags + filtrado |
| `windows/scripts/install-opencode.ps1` | Modified | Flags + filtrado |
| `installer/internal/tui/view.go` | Modified | Pantalla selección skills |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Skills sin manifest no se instalan | Low | Agregar todos los skills actuales al manifest |
| Breaking change para usuarios actuales | Low | `--skills=all` es default |

## Rollback Plan

```bash
git checkout HEAD~1 -- scripts/install-opencode.sh windows/scripts/install-opencode.ps1 configs/opencode/
```

## Dependencies

- Ninguna external

## Success Criteria

- [ ] `install-opencode.sh --skills=sdd-init` solo instala sdd-init
- [ ] `install-opencode.sh --exclude-skills=mermaid` instala todo menos mermaid
- [ ] TUI muestra checkbox list de skills y permite selección
- [ ] Tests existentes siguen pasando
