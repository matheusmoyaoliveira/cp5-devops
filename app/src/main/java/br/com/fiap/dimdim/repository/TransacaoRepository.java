package br.com.fiap.dimdim.repository;

import br.com.fiap.dimdim.model.Transacao;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TransacaoRepository extends JpaRepository<Transacao, Integer> {

    List<Transacao> findAllByOrderByDataTransacaoDesc();

    List<Transacao> findByClienteIdOrderByDataTransacaoDesc(Integer clienteId);

    boolean existsByClienteId(Integer clienteId);
}