package br.com.fiap.dimdim.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;
import java.time.ZoneId;

@Entity
@Table(name = "clientes")
@Getter
@Setter
@NoArgsConstructor
public class Cliente {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @NotBlank(message = "Informe o nome")
    @Size(max = 100, message = "Nome deve ter no máximo 100 caracteres")
    @Column(nullable = false, length = 100)
    private String nome;

    @NotBlank(message = "Informe o CPF")
    @Pattern(regexp = "\\d{11}", message = "CPF deve ter 11 dígitos, só números")
    @Column(nullable = false, length = 11, unique = true)
    private String cpf;

    @NotBlank(message = "Informe o e-mail")
    @Email(message = "E-mail inválido")
    @Size(max = 150)
    @Column(nullable = false, length = 150, unique = true)
    private String email;

    @Size(max = 20)
    @Column(length = 20)
    private String telefone;

    @Column(name = "data_cadastro", nullable = false, updatable = false)
    private LocalDateTime dataCadastro;

    @PrePersist
    void aoCriar() {
        dataCadastro = LocalDateTime.now(ZoneId.of("America/Sao_Paulo"));
    }
}