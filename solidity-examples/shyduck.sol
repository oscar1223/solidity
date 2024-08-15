// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Timers.sol";

/**
 * @title ShyduckToken
 * @dev ERC20 Token llamado Shyduck que incluye un mecanismo de quema automática de tokens cada 3 meses.
 */
contract ShyduckToken is ERC20, Ownable, ReentrancyGuard {
    using Timers for Timers.Timestamp;

    /// @notice La cantidad fija de tokens que se quemarán cada 3 meses.
    uint256 public constant BURN_AMOUNT = 1_000_000 * 10 ** 18;

    /// @notice El tiempo entre cada quema de tokens (3 meses en segundos).
    uint256 public constant BURN_INTERVAL = 90 days;

    /// @notice El temporizador para la próxima quema de tokens.
    Timers.Timestamp private nextBurnTime;

    /**
     * @dev Inicializa el contrato con un suministro total de 1,000,000,000 tokens Shyduck.
     * Se establece el temporizador para la primera quema.
     */
    constructor() ERC20("Shyduck", "SHD") {
        _mint(msg.sender, 1_000_000_000 * 10 ** 18);
        nextBurnTime.setDeadline(block.timestamp + BURN_INTERVAL);
    }

    /**
     * @notice Función pública para realizar la quema periódica de tokens.
     * @dev Solo puede ser llamada por el propietario y solo cuando ha pasado el tiempo suficiente.
     */
    function burnTokens() external onlyOwner nonReentrant {
        require(
            nextBurnTime.isExpired(),
            unicode"La quema de tokens aún no está disponible."
        );
        require(
            balanceOf(address(this)) >= BURN_AMOUNT,
            unicode"No hay suficientes tokens para quemar."
        );

        _burn(address(this), BURN_AMOUNT);
        nextBurnTime.reset(BURN_INTERVAL);
    }

    /**
     * @notice Función que permite al propietario depositar tokens en el contrato para la quema.
     * @param amount La cantidad de tokens a depositar.
     */
    function depositTokensForBurn(
        uint256 amount
    ) external onlyOwner nonReentrant {
        _transfer(msg.sender, address(this), amount);
    }

    /**
     * @dev Función para saber cuándo será la próxima quema.
     * @return La marca de tiempo de la próxima quema en formato Unix.
     */
    function getNextBurnTime() external view returns (uint256) {
        return nextBurnTime.getDeadline();
    }
}
