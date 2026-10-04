package br.com.fiap.dimdim.service;

import br.com.fiap.dimdim.exception.RegraNegocioException;
import br.com.fiap.dimdim.model.Cliente;
import br.com.fiap.dimdim.model.Transacao;
import br.com.fiap.dimdim.repository.TransacaoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class TransacaoService {

    private final TransacaoRepository transacaoRepository;
    private final ClienteService clienteService;

    public List<Transacao> listar() {
        return transacaoRepository.findAllByOrderByDataTransacaoDesc();
    }

    public List<Transacao> listarPorCliente(Integer clienteId) {
        return transacaoRepository.findByClienteIdOrderByDataTransacaoDesc(clienteId);
    }

    public Transacao buscarPorId(Integer id) {
        return transacaoRepository.findById(id)
                .orElseThrow(() -> new RegraNegocioException("Transação não encontrada: " + id));
    }

    @Transactional
    public Transacao salvar(Transacao transacao) {
        Cliente cliente = clienteDoFormulario(transacao);

        if (transacao.getId() == null) {
            transacao.setCliente(cliente);
            return transacaoRepository.save(transacao);
        }

        Transacao existente = buscarPorId(transacao.getId());
        existente.setDescricao(transacao.getDescricao());
        existente.setTipo(transacao.getTipo());
        existente.setValor(transacao.getValor());
        existente.setCliente(cliente);
        return existente;
    }

    @Transactional
    public void excluir(Integer id) {
        transacaoRepository.delete(buscarPorId(id));
    }

    private Cliente clienteDoFormulario(Transacao transacao) {
        if (transacao.getCliente() == null || transacao.getCliente().getId() == null) {
            throw new RegraNegocioException("Selecione o cliente da transação.");
        }
        return clienteService.buscarPorId(transacao.getCliente().getId());
    }
}