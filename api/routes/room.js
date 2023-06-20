import express from "express";
import {
  getRoomsByHotel,
  addRoom,
  updateRoom,
  deleteRoom,
} from "../controllers/room.js";

const router = express.Router();

// get room by hotel
router.get("/:hotelId", getRoomsByHotel);

// add room
router.post("/:hotelId", addRoom);

// update room
router.put("/:roomId", updateRoom);

// delete room
router.delete("/:roomId", deleteRoom);

export default router;
