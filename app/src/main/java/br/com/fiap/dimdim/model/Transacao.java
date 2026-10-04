package br.com.fiap.dimdim.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.ZoneId;

@Entity
@Table(name = "transacoes")
@Getter
@Setter
@NoArgsConstructor
public class Transacao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @NotBlank(message = "Informe a descrição")
    @Size(max = 255)
    @Column(nullable = false, length = 255)
    private String descricao;

    @NotNull(message = "Selecione o tipo")
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private TipoTransacao tipo;

    @NotNull(message = "Informe o valor")
    @Positive(message = "O valor deve ser maior que zero")
    @Digits(integer = 8, fraction = 2, message = "Até 8 dígitos e 2 casas decimais")
    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal valor;

    @Column(name = "data_transacao", nullable = false, updatable = false)
    private LocalDateTime dataTransacao;

    @NotNull(message = "Selecione o cliente")
    @ManyToOne(optional = false)
    @JoinColumn(name = "cliente_id", nullable = false)
    private Cliente cliente;

    @PrePersist
    void aoCriar() {
        dataTransacao = LocalDateTime.now(ZoneId.of("America/Sao_Paulo"));
    }
}