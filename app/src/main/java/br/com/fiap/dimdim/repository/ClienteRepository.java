package br.com.fiap.dimdim.repository;

import br.com.fiap.dimdim.model.Cliente;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ClienteRepository extends JpaRepository<Cliente, Integer> {

    List<Cliente> findAllByOrderByNomeAsc();

    boolean existsByCpfAndIdNot(String cpf, Integer id);

    boolean existsByEmailAndIdNot(String email, Integer id);
}