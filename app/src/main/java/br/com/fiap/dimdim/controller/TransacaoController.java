package br.com.fiap.dimdim.controller;

import br.com.fiap.dimdim.exception.RegraNegocioException;
import br.com.fiap.dimdim.model.Cliente;
import br.com.fiap.dimdim.model.TipoTransacao;
import br.com.fiap.dimdim.model.Transacao;
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
@RequestMapping("/transacoes")
@RequiredArgsConstructor
public class TransacaoController {

    private final TransacaoService transacaoService;
    private final ClienteService clienteService;

    @GetMapping
    public String listar(Model model) {
        model.addAttribute("transacoes", transacaoService.listar());
        return "transacoes/list";
    }

    @GetMapping("/{id}")
    public String detalhes(@PathVariable Integer id, Model model) {
        model.addAttribute("transacao", transacaoService.buscarPorId(id));
        return "transacoes/details";
    }

    @GetMapping("/novo")
    public String novo(@RequestParam(required = false) Integer clienteId, Model model) {
        Transacao transacao = new Transacao();
        transacao.setCliente(new Cliente());
        transacao.getCliente().setId(clienteId);

        model.addAttribute("transacao", transacao);
        return prepararFormulario(model);
    }

    @GetMapping("/{id}/editar")
    public String editar(@PathVariable Integer id, Model model) {
        model.addAttribute("transacao", transacaoService.buscarPorId(id));
        return prepararFormulario(model);
    }

    private String prepararFormulario(Model model) {
        model.addAttribute("clientes", clienteService.listar());
        model.addAttribute("tipos", TipoTransacao.values());
        return "transacoes/form";
    }

    @PostMapping
    public String criar(@Valid @ModelAttribute("transacao") Transacao transacao,
                        BindingResult result,
                        Model model,
                        RedirectAttributes redirect) {
        transacao.setId(null);
        return salvar(transacao, result, model, redirect, "Transação cadastrada com sucesso!");
    }

    @PutMapping("/{id}")
    public String atualizar(@PathVariable Integer id,
                            @Valid @ModelAttribute("transacao") Transacao transacao,
                            BindingResult result,
                            Model model,
                            RedirectAttributes redirect) {
        transacao.setId(id);
        return salvar(transacao, result, model, redirect, "Transação atualizada com sucesso!");
    }

    @DeleteMapping("/{id}")
    public String excluir(@PathVariable Integer id, RedirectAttributes redirect) {
        try {
            transacaoService.excluir(id);
            redirect.addFlashAttribute("sucesso", "Transação excluída com sucesso!");
        } catch (RegraNegocioException e) {
            redirect.addFlashAttribute("erro", e.getMessage());
        }
        return "redirect:/transacoes";
    }

    private String salvar(Transacao transacao,
                          BindingResult result,
                          Model model,
                          RedirectAttributes redirect,
                          String mensagemSucesso) {
        if (result.hasErrors()) {
            return prepararFormulario(model);
        }
        try {
            transacaoService.salvar(transacao);
        } catch (RegraNegocioException e) {
            model.addAttribute("erro", e.getMessage());
            return prepararFormulario(model);
        }
        redirect.addFlashAttribute("sucesso", mensagemSucesso);
        return "redirect:/transacoes";
    }
}