# Beast Capital Website

A static website built with Hakyll for Beast Capital investment firm.

## Building

```bash
stack build
stack exec site build
```

## Development

```bash
stack exec site watch
```

## Docker

```bash
docker build -t beast-capital .
docker run -p 8080:80 beast-capital
```