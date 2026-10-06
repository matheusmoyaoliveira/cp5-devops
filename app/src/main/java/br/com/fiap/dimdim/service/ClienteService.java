package br.com.fiap.dimdim.service;

import br.com.fiap.dimdim.exception.RegraNegocioException;
import br.com.fiap.dimdim.model.Cliente;
import br.com.fiap.dimdim.repository.ClienteRepository;
import br.com.fiap.dimdim.repository.TransacaoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ClienteService {

    private final ClienteRepository clienteRepository;
    private final TransacaoRepository transacaoRepository;

    public List<Cliente> listar() {
        return clienteRepository.findAllByOrderByNomeAsc();
    }

    public Cliente buscarPorId(Integer id) {
        return clienteRepository.findById(id)
                .orElseThrow(() -> new RegraNegocioException("Cliente não encontrado: " + id));
    }

    @Transactional
    public Cliente salvar(Cliente cliente) {
        validarDuplicidade(cliente);

        if (cliente.getId() == null) {
            return clienteRepository.save(cliente);
        }

        Cliente existente = buscarPorId(cliente.getId());
        existente.setNome(cliente.getNome());
        existente.setCpf(cliente.getCpf());
        existente.setEmail(cliente.getEmail());
        existente.setTelefone(cliente.getTelefone());
        return existente;
    }

    @Transactional
    public void excluir(Integer id) {
        Cliente cliente = buscarPorId(id);

        if (transacaoRepository.existsByClienteId(id)) {
            throw new RegraNegocioException(
                    "Não é possível excluir " + cliente.getNome()
                    + ": o cliente possui transações. Exclua as transações primeiro.");
        }
        clienteRepository.delete(cliente);
    }

    private void validarDuplicidade(Cliente cliente) {
        Integer id = cliente.getId() == null ? 0 : cliente.getId();

        if (clienteRepository.existsByCpfAndIdNot(cliente.getCpf(), id)) {
            throw new RegraNegocioException("Já existe um cliente com este CPF.");
        }
        if (clienteRepository.existsByEmailAndIdNot(cliente.getEmail(), id)) {
            throw new RegraNegocioException("Já existe um cliente com este e-mail.");
        }
    }
}