package br.com.fiap.dimdim.model;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum TipoTransacao {

    DEPOSITO("Depósito"),
    SAQUE("Saque"),
    PIX("PIX"),
    TRANSFERENCIA("Transferência"),
    PAGAMENTO("Pagamento");

    private final String descricao;
}