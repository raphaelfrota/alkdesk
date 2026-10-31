"""Monta um .ico com entradas PNG (aceito desde o Windows Vista).

Uso: python3 -I ico.py saida.ico 16.png 32.png ... (lado lido do cabeçalho PNG)
"""
import struct
import sys


def lado_png(dados):
    if dados[:8] != b"\x89PNG\r\n\x1a\n":
        raise SystemExit("não é PNG")
    w, h = struct.unpack(">II", dados[16:24])
    if w != h or w > 256:
        raise SystemExit(f"PNG precisa ser quadrado e até 256px: {w}x{h}")
    return w


def main():
    saida, entradas = sys.argv[1], sys.argv[2:]
    imagens = []
    for caminho in entradas:
        with open(caminho, "rb") as f:
            dados = f.read()
        imagens.append((lado_png(dados), dados))
    imagens.sort()

    cabecalho = struct.pack("<HHH", 0, 1, len(imagens))
    diretorio = b""
    corpo = b""
    deslocamento = 6 + 16 * len(imagens)
    for lado, dados in imagens:
        b = 0 if lado == 256 else lado
        diretorio += struct.pack("<BBBBHHII", b, b, 0, 0, 1, 32, len(dados), deslocamento)
        corpo += dados
        deslocamento += len(dados)

    with open(saida, "wb") as f:
        f.write(cabecalho + diretorio + corpo)


main()
