#pragma warning disable 168
using System;
using System.Collections;

namespace Leaf;

struct MidiEvent
{
	public enum Type
	{
		NoteOff,
		NoteOn,
		Other
	}

	public Type event = 0;
	public uint8 nKey = 0;
	public uint8 nVelocity = 0;
	public uint32 nDeltaTick = 0;

	public this(Type t)
	{
		event = t;
	}

	public this(Type t, uint8 key, uint8 velocity, uint32 deltaTick)
	{
		event = t;
		nKey = key;
		nVelocity = velocity;
		nDeltaTick = deltaTick;
	}
}

struct MidiNote
{
	public uint8 nKey = 0;
	public uint8 nVelocity = 0;
	public uint32 nStartTime = 0;
	public uint32 nDuration = 0;

	public this(uint8 pKey, uint8 pVelocity, uint32 pStartTime, uint32 pDuration)
	{
		nKey = pKey;
		nVelocity = pVelocity;
		nStartTime = pStartTime;
		nDuration = pDuration;
	}
}

class MidiTrack
{
	public String sName;
	public String sInstrument;
	public List<MidiEvent> Events = new .() ~ delete _;
	public List<MidiNote> Notes = new .() ~ delete _;
	public uint8 nMaxNote = 64;
	public uint8 nMinNote = 64;

	public ~this()
	{
		delete sName;
		delete sInstrument;
	}
}

class MidiFile
{
	public enum EventName : uint8
	{					
		VoiceNoteOff = 0x80,
		VoiceNoteOn = 0x90,
		VoiceAftertouch = 0xA0,
		VoiceControlChange = 0xB0,
		VoiceProgramChange = 0xC0,
		VoiceChannelPressure = 0xD0,
		VoicePitchBend = 0xE0,
		SystemExclusive = 0xF0,		
	}

	public enum MetaEventName : uint8
	{
		MetaSequence = 0x00,
		MetaText = 0x01,
		MetaCopyright = 0x02,
		MetaTrackName = 0x03,
		MetaInstrumentName = 0x04,
		MetaLyrics = 0x05,
		MetaMarker = 0x06,
		MetaCuePoint = 0x07,
		MetaChannelPrefix = 0x20,
		MetaEndOfTrack = 0x2F,
		MetaSetTempo = 0x51,
		MetaSMPTEOffset = 0x54,
		MetaTimeSignature = 0x58,
		MetaKeySignature = 0x59,
		MetaSequencerSpecific = 0x7F,

		MetaProgramName = 0x8,
		MetaDevicePort = 0x9,
		MetaMidiPort = 0x21,
	}

	public List<MidiTrack> Tracks = new .();
	public uint32 m_nTempo = 0;
	public uint32 m_nBPM = 0;

	public this()
	{
	}

	public this(String sFileName)
	{
		ParseFile(sFileName);
	}

	public ~this()
	{
		for(var e in Tracks)
			delete e;
		delete Tracks;
	}

	public void Clear()
	{

	}

	public bool ParseFile(String sFileName)
	{
		// Open the MIDI File as a stream
		System.IO.FileStream ifs = scope .();
		ifs.Open(sFileName);

		// Helper Utilities ====================
		// Swaps byte order of 32-bit integer
		uint32 Swap32(uint32 n)
		{
			return (((n >> 24) & 0xff) | ((n << 8) & 0xff0000) | ((n >> 8) & 0xff00) | ((n << 24) & 0xff000000));
		}

		// Swaps byte order of 16-bit integer
		uint16 Swap16(uint16 n)
		{
			return ((n >> 8) | (n << 8));
		}

		// Reads nLength bytes form file stream, and constructs a text string
		String ReadString(uint32 nLength)
		{
			String s = scope:: .();
			for (uint32 i = 0; i < nLength; i++)
				s += ifs.Read<char8>();
			return s;
		}

		String ReadStringAlloc(uint32 nLength)
		{
			String s = new .();
			for (uint32 i = 0; i < nLength; i++)
				s += ifs.Read<char8>();
			return s;
		}

		//String newString = ReadStringAlloc(123);

		// Reads a compressed MIDI value. This can be up to 32 bits long. Essentially if the first byte, first
		// bit is set to 1, that indicates that the next byte is required to construct the full word. Only
		// the bottom 7 bits of each byte are used to construct the final word value. Each successive byte 
		// that has MSB set, indicates a further byte needs to be read.
		uint32 ReadValue()
		{
			uint32 nValue = 0;
			uint8 nByte = 0;

			// Read byte
			nValue = ifs.Read<uint8>();

			// Check MSB, if set, more bytes need reading
			if ((nValue & 0x80) != 0)
			{
				// Extract bottom 7 bits of read byte
				nValue &= 0x7F;
				repeat
				{
					// Read next byte
					nByte = ifs.Read<uint8>();

					// Construct value by setting bottom 7 bits, then shifting 7 bits
					nValue = (nValue << 7) | (nByte & 0x7F);
				} 
				while ((nByte & 0x80) != 0); // Loop whilst read byte MSB is 1
			}

			// Return final construction (always 32-bit unsigned integer internally)
			return nValue;
		}

		uint32 n32 = 0;
		uint16 n16 = 0;

		// Read MIDI Header (Fixed Size)
		n32 = ifs.Read<uint32>();
		uint32 nFileID = Swap32(n32);

		n32 = ifs.Read<uint32>();
		uint32 nHeaderLength = Swap32(n32);

		n16 = ifs.Read<uint16>();
		uint16 nFormat = Swap16(n16);

		n16 = ifs.Read<uint16>();
		uint16 nTrackChunks = Swap16(n16);

		n16 = ifs.Read<uint16>();
		uint16 nDivision = Swap16(n16);

		Console.WriteLine(nTrackChunks);

		for (uint16 nChunk = 0; nChunk < nTrackChunks; nChunk++)
		{
			Console.WriteLine("========= NEW TRACK");

			// Read Track Header
			n32 = ifs.Read<uint32>();
			uint32 nTrackID = Swap32(n32);
			n32 = ifs.Read<uint32>();
			uint32 nTrackLength = Swap32(n32);

			bool bEndOfTrack = false;

			Tracks.Add(new MidiTrack());

			uint32 nWallTime = 0;

			uint8 nPreviousStatus = 0;

			while (!ifs.IsEmpty && !bEndOfTrack)
			{
				// Fundamentally all MIDI Events contain a timecode, and a status byte*
				uint32 nStatusTimeDelta = 0;
				uint8 nStatus = 0;

				// Read Timecode from MIDI stream. This could be variable in length
				// and is the delta in "ticks" from the previous event. Of course this value
				// could be 0 if two events happen simultaneously.
				nStatusTimeDelta = ReadValue();

				// Read first byte of message, this could be the status byte, or it could not...
				nStatus = ifs.Read<uint8>();

				// All MIDI Status events have the MSB set. The data within a standard MIDI event
				// does not. A crude yet utilised form of compression is to omit sending status
				// bytes if the following sequence of events all refer to the same MIDI Status.
				// This is called MIDI Running Status, and is essential to succesful decoding of
				// MIDI streams and files.
				//
				// If the MSB of the read byte was not set, and on the whole we were expecting a
				// status byte, then Running Status is in effect, so we refer to the previous 
				// confirmed status byte.
				if (nStatus < 0x80)
				{
					// MIDI Running Status is happening, so refer to previous valid MIDI Status byte
					nStatus = nPreviousStatus;

					// We had to read the byte to assess if MIDI Running Status is in effect. But!
					// that read removed the byte form the stream, and that will desync all of the 
					// following code because normally we would have read a status byte, but instead
					// we have read the data contained within a MIDI message. The simple solution is 
					// to put the byte back :P
					//ifs.seekg(-1, std.ios_base.cur);
					ifs.Seek(-1, .Relative);
				}

				if ((EventName)(nStatus & 0xF0) == EventName.VoiceNoteOff)
				{
					nPreviousStatus = nStatus;
					uint8 nChannel = nStatus & 0x0F;
					uint8 nNoteID = ifs.Read<uint8>();
					uint8 nNoteVelocity = ifs.Read<uint8>();
					Tracks[nChunk].Events.Add(.(MidiEvent.Type.NoteOff, nNoteID, nNoteVelocity, nStatusTimeDelta));
				}

				else if ((EventName)(nStatus & 0xF0) == EventName.VoiceNoteOn)
				{
					nPreviousStatus = nStatus;
					uint8 nChannel = nStatus & 0x0F;
					uint8 nNoteID = ifs.Read<uint8>();
					uint8 nNoteVelocity = ifs.Read<uint8>();
					if(nNoteVelocity == 0)
						Tracks[nChunk].Events.Add(.(MidiEvent.Type.NoteOff, nNoteID, nNoteVelocity, nStatusTimeDelta));
					else
						Tracks[nChunk].Events.Add(.(MidiEvent.Type.NoteOn, nNoteID, nNoteVelocity, nStatusTimeDelta));
				}

				else if ((EventName)(nStatus & 0xF0) == EventName.VoiceAftertouch)
				{
					nPreviousStatus = nStatus;
					uint8 nChannel = nStatus & 0x0F;
					uint8 nNoteID = ifs.Read<uint8>();
					uint8 nNoteVelocity = ifs.Read<uint8>();
					Tracks[nChunk].Events.Add(.(MidiEvent.Type.Other));
				}

				else if ((EventName)(nStatus & 0xF0) == EventName.VoiceControlChange)
				{
					nPreviousStatus = nStatus;
					uint8 nChannel = nStatus & 0x0F;
					uint8 nControlID = ifs.Read<uint8>();
					uint8 nControlValue = ifs.Read<uint8>();
					Tracks[nChunk].Events.Add(.(MidiEvent.Type.Other));
				}

				else if ((EventName)(nStatus & 0xF0) == EventName.VoiceProgramChange)
				{
					nPreviousStatus = nStatus;
					uint8 nChannel = nStatus & 0x0F;
					uint8 nProgramID = ifs.Read<uint8>();					
					Tracks[nChunk].Events.Add(.(MidiEvent.Type.Other));
				}

				else if ((EventName)(nStatus & 0xF0) == EventName.VoiceChannelPressure)
				{
					nPreviousStatus = nStatus;
					uint8 nChannel = nStatus & 0x0F;
					uint8 nChannelPressure = ifs.Read<uint8>();
					Tracks[nChunk].Events.Add(.(MidiEvent.Type.Other));
				}

				else if ((EventName)(nStatus & 0xF0) == EventName.VoicePitchBend)
				{
					nPreviousStatus = nStatus;
					uint8 nChannel = nStatus & 0x0F;
					uint8 nLS7B = ifs.Read<uint8>();
					uint8 nMS7B = ifs.Read<uint8>();
					Tracks[nChunk].Events.Add(.(MidiEvent.Type.Other));

				}

				else if ((EventName)(nStatus & 0xF0) == EventName.SystemExclusive)
				{
					nPreviousStatus = 0;

					if (nStatus == 0xFF)
					{
						// Meta Message
						uint8 nType = ifs.Read<uint8>();
						uint8 nLength = (uint8)ReadValue();

						switch ((MetaEventName)nType)
						{
						case .MetaSequence:
							Console.WriteLine(scope $"Sequence Number: {ifs.Read<uint8>()} {ifs.Read<uint8>()}");
							break;
						case .MetaText:
							Console.WriteLine(scope $"Text: {ReadString(nLength)}");
							break;
						case .MetaCopyright:
							Console.WriteLine(scope $"Copyright: {ReadString(nLength)}");
							break;
						case .MetaTrackName:
							Tracks[nChunk].sName = ReadStringAlloc(nLength);
							Console.WriteLine(scope $"Track Name: {Tracks[nChunk].sName}");							
							break;
						case .MetaInstrumentName:
							Tracks[nChunk].sInstrument = ReadStringAlloc(nLength);
							Console.WriteLine(scope $"Instrument Name: {Tracks[nChunk].sInstrument}");
							break;
						case .MetaLyrics:
							Console.WriteLine(scope $"Lyrics: {ReadString(nLength)}");
							break;
						case .MetaMarker:
							Console.WriteLine(scope $"Marker: {ReadString(nLength)}");
							break;
						case .MetaCuePoint:
							Console.WriteLine(scope $"Cue: {ReadString(nLength)}");
							break;
						case .MetaChannelPrefix:
							Console.WriteLine(scope $"Prefix: {ifs.Read<uint8>()}");
							break;
						case .MetaEndOfTrack:
							bEndOfTrack = true;
							break;
						case .MetaSetTempo:
							// Tempo is in microseconds per quarter note	
							if (m_nTempo == 0)
							{
								ifs.Read<uint8>();
								ifs.Read<uint8>();
								ifs.Read<uint8>();

								/*
								m_nTempo |= (ifs.Read<uint8>() << 16);
								m_nTempo |= (ifs.Read<uint8>() << 8);
								m_nTempo |= (ifs.Read<uint8>() << 0);
								*/
								//m_nBPM = (60000000 / m_nTempo);
								Console.WriteLine(scope $"Tempo: {m_nTempo} ({m_nBPM} bpm)");
							}
							break;
						case .MetaSMPTEOffset:
							Console.WriteLine(scope $"SMPTE: H: {ifs.Read<uint8>()} M: {ifs.Read<uint8>()} S: {ifs.Read<uint8>()} FR: {ifs.Read<uint8>()} FF: {ifs.Read<uint8>()}");
							break;
						case .MetaTimeSignature:
							Console.WriteLine(scope $"Time Signature: {ifs.Read<uint8>()} / {(2 << ifs.Read<uint8>())}");
							Console.WriteLine(scope $"ClocksPerTick: {ifs.Read<uint8>()}");

							// A MIDI "Beat" is 24 ticks, so specify how many 32nd notes constitute a beat
							Console.WriteLine(scope $"32per24Clocks: {ifs.Read<uint8>()}");
							break;
						case .MetaKeySignature:
							Console.WriteLine(scope $"Key Signature: {ifs.Read<uint8>()}");
							Console.WriteLine(scope $"Minor Key: {ifs.Read<uint8>()}");
							break;
						case .MetaSequencerSpecific:
							Console.WriteLine(scope $"Sequencer Specific: {ReadString(nLength)}");
							break;
						default:
							Console.WriteLine(scope $"Unrecognised MetaEvent: {nType}");
						}
					}

					if (nStatus == 0xF0)
					{
						// System Exclusive Message Begin
						Console.WriteLine(scope $"System Exclusive Begin: {ReadString(ReadValue())}");
					}

					if (nStatus == 0xF7)
					{
						// System Exclusive Message Begin
						Console.WriteLine(scope $"System Exclusive End: {ReadString(ReadValue())}");
					}
				}			
				else
				{
					Console.WriteLine(scope $"Unrecognised Status Byte: {nStatus}");
				}
			}
		}

		// Convert Time Events to Notes
		for (var track in Tracks)
		{
			uint32 nWallTime = 0;

			List<MidiNote> listNotesBeingProcessed = scope .();

			for (var event in track.Events)
			{
				nWallTime += event.nDeltaTick;

				if (event.event == MidiEvent.Type.NoteOn)
				{
					// New Note
					listNotesBeingProcessed.Add(.(event.nKey, event.nVelocity, nWallTime, 0));
				}

				if (event.event == MidiEvent.Type.NoteOff)
				{
					var index = listNotesBeingProcessed.FindIndex(scope (n) => n.nKey == event.nKey);

					if (index != -1)
					{
						var note = listNotesBeingProcessed[index];
						note.nDuration = nWallTime - note.nStartTime;
						track.Notes.Add(note);
						track.nMinNote = Math.Min(track.nMinNote, note.nKey);
						track.nMaxNote = Math.Max(track.nMaxNote, note.nKey);
						listNotesBeingProcessed.RemoveAt(index);
						//listNotesBeingProcessed.Remove(note);
					}
					else
					{
						Console.WriteLine("ERROR NOTE NOT FOUND");
					}
				}
			}
		}

		return true;
	}

}

/*
class MidiReader
{
	MidiFile midi;

	double dSongTime = 0.0;
	double dRunTime = 0.0;
	uint32 nMidiClock = 0;

	float nTrackOffset = 1000;

	bool OnUserUpdate(float fElapsedTime) override
	{
		uint32 nTimePerColumn = 50;
		uint32 nNoteHeight = 2;
		uint32 nOffsetY = 0;
		
		if (GetKey(olc.Key.LEFT).bHeld) nTrackOffset -= 10000.0f * fElapsedTime;
		if (GetKey(olc.Key.RIGHT).bHeld) nTrackOffset += 10000.0f * fElapsedTime;

		for (auto& track : midi.vecTracks)
		{
			if (!track.vecNotes.empty())
			{
				uint32 nNoteRange = track.nMaxNote - track.nMinNote;

				FillRect(0, nOffsetY, ScreenWidth(), (nNoteRange + 1) * nNoteHeight, olc.DARK_GREY);
				DrawString(1, nOffsetY + 1, track.sName);

				for (auto& note : track.vecNotes)
				{
					FillRect((note.nStartTime - nTrackOffset) / nTimePerColumn, (nNoteRange - (note.nKey - track.nMinNote)) * nNoteHeight + nOffsetY, note.nDuration / nTimePerColumn, nNoteHeight, olc.WHITE);
				}
				 
				nOffsetY += (nNoteRange + 1) * nNoteHeight + 4;
			}
		}

		// BELOW - ABSOLUTELY HORRIBLE BODGE TO PLAY SOUND
		// DO NOT USE THIS CODE...
		
		/*
		dRunTime += fElapsedTime;
		uint32 nTempo = 4;
		int nTrack = 1;
		while (dRunTime >= 1.0 / double(midi.m_nBPM * 8))
		{
			dRunTime -= 1.0 / double(midi.m_nBPM * 8);

			// Single MIDI Clock
			nMidiClock++;

			int i = 0;
			int nTrack = 1;
			//for (nTrack = 1; nTrack < 3; nTrack++)
			{
				if (nCurrentNote[nTrack] < midi.vecTracks[nTrack].vecEvents.size())
				{
					if (midi.vecTracks[nTrack].vecEvents[nCurrentNote[nTrack]].nDeltaTick == 0)
					{
						uint32 nStatus = 0;
						uint32 nNote = midi.vecTracks[nTrack].vecEvents[nCurrentNote[nTrack]].nKey;
						uint32 nVelocity = midi.vecTracks[nTrack].vecEvents[nCurrentNote[nTrack]].nVelocity;

						if (midi.vecTracks[nTrack].vecEvents[nCurrentNote[nTrack]].event == MidiEvent.Type.NoteOn)
							nStatus = 0x90;
						else
							nStatus = 0x80;

						midiOutShortMsg(hInstrument, (nVelocity << 16) | (nNote << 8) | nStatus);
						nCurrentNote[nTrack]++;
					}
					else
						midi.vecTracks[nTrack].vecEvents[nCurrentNote[nTrack]].nDeltaTick--;
				}
			}
		}

		if (GetKey(olc.Key.SPACE).bPressed)
		{
			midiOutShortMsg(hInstrument, 0x00403C90);
		}

		if (GetKey(olc.Key.SPACE).bReleased)
		{
			midiOutShortMsg(hInstrument, 0x00003C80);
		}
		*/

	}
}
*/