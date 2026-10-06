package br.com.fiap.dimdim.controller;

import br.com.fiap.dimdim.exception.RegraNegocioException;
import br.com.fiap.dimdim.model.Cliente;
import br.com.fiap.dimdim.service.ClienteService;
import br.com.fiap.dimdim.service.TransacaoService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/clientes")
@RequiredArgsConstructor
public class ClienteController {

    private final ClienteService clienteService;
    private final TransacaoService transacaoService;

    @GetMapping
    public String listar(Model model) {
        model.addAttribute("clientes", clienteService.listar());
        return "clientes/list";
    }

    @GetMapping("/{id}")
    public String detalhes(@PathVariable Integer id, Model model) {
        model.addAttribute("cliente", clienteService.buscarPorId(id));
        model.addAttribute("transacoes", transacaoService.listarPorCliente(id));
        return "clientes/details";
    }

    @GetMapping("/novo")
    public String novo(Model model) {
        model.addAttribute("cliente", new Cliente());
        return "clientes/form";
    }

    @GetMapping("/{id}/editar")
    public String editar(@PathVariable Integer id, Model model) {
        model.addAttribute("cliente", clienteService.buscarPorId(id));
        return "clientes/form";
    }

    @PostMapping
    public String criar(@Valid @ModelAttribute("cliente") Cliente cliente,
                        BindingResult result,
                        Model model,
                        RedirectAttributes redirect) {
        cliente.setId(null);
        return salvar(cliente, result, model, redirect, "Cliente cadastrado com sucesso!");
    }

    @PutMapping("/{id}")
    public String atualizar(@PathVariable Integer id,
                            @Valid @ModelAttribute("cliente") Cliente cliente,
                            BindingResult result,
                            Model model,
                            RedirectAttributes redirect) {
        cliente.setId(id);
        return salvar(cliente, result, model, redirect, "Cliente atualizado com sucesso!");
    }

    @DeleteMapping("/{id}")
    public String excluir(@PathVariable Integer id, RedirectAttributes redirect) {
        try {
            clienteService.excluir(id);
            redirect.addFlashAttribute("sucesso", "Cliente excluído com sucesso!");
        } catch (RegraNegocioException e) {
            redirect.addFlashAttribute("erro", e.getMessage());
        }
        return "redirect:/clientes";
    }

    private String salvar(Cliente cliente,
                          BindingResult result,
                          Model model,
                          RedirectAttributes redirect,
                          String mensagemSucesso) {
        if (result.hasErrors()) {
            return "clientes/form";
        }
        try {
            clienteService.salvar(cliente);
        } catch (RegraNegocioException e) {
            model.addAttribute("erro", e.getMessage());
            return "clientes/form";
        }
        redirect.addFlashAttribute("sucesso", mensagemSucesso);
        return "redirect:/clientes";
    }
}